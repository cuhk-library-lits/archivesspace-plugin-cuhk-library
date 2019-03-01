require 'tempfile'

class FindingAidPDFUni

  DEPTH_1_LEVELS = ['collection', 'recordgrp', 'series']
  DEPTH_2_LEVELS = ['subgrp', 'subseries', 'subfonds']

  attr_reader :repo_id, :resource_id, :archivesspace, :base_url, :repo_code

  PLUGIN_LIB_PATH = File.expand_path("../..", File.dirname(__FILE__)).to_s + "/common/lib"
  Dir.foreach(PLUGIN_LIB_PATH) do |lib_file|
    next if lib_file == '.' or lib_file == '..'
    $CLASSPATH << PLUGIN_LIB_PATH + "/" + lib_file
  end

  def initialize(repo_id, resource_id, archivesspace_client, base_url)
    @repo_id = repo_id
    @resource_id = resource_id
    @archivesspace = archivesspace_client
    @base_url = base_url

    @resource = archivesspace.get_record("/repositories/#{repo_id}/resources/#{resource_id}")
    @ordered_records = archivesspace.get_record("/repositories/#{repo_id}/resources/#{resource_id}/ordered_records")

    # make sure finding aid title isn't only like /^\n$/
    if @resource.finding_aid['title'] and @resource.finding_aid['title'] =~ /\w/
      @short_title = @resource.finding_aid['title'].lstrip.split("\n")[0].strip
    end
  end

  def suggested_filename
    # Use the EAD ID.  If that's missing, use the 4-part identifier
    filename = (@resource.ead_id || @resource.four_part_identifier.reject(&:blank?).join('_'))

    # no spaces, please.
    filename.gsub(' ', '_') + '.pdf'
  end

  def short_title
    @short_title || suggested_filename
  end

  def source_file
    # We'll use the original controller so we can find and render the PDF
    # partials, but just for its ERB rendering.
    renderer = PdfController.new
    start_time = Time.now

    @repo_code = @resource.repository_information.fetch('top').fetch('repo_code')

    # .length == 1 would be just the resource itself.
    has_children = @ordered_records.entries.length > 1

    out_html = Tempfile.new
    out_html.write(renderer.render_to_string partial: 'header', layout: false, :locals => {:record => @resource})

    out_html.write(renderer.render_to_string partial: 'titlepage', layout: false, :locals => {:record => @resource})

    # Drop the resource and filter the AOs
    toc_aos = @ordered_records.entries.drop(1).select {|entry|
      if entry.depth == 1
        DEPTH_1_LEVELS.include?(entry.level)
      elsif entry.depth == 2
        DEPTH_2_LEVELS.include?(entry.level)
      else
        false
      end
    }

    out_html.write(renderer.render_to_string partial: 'toc', layout: false, :locals => {:resource => @resource, :has_children => has_children, :ordered_aos => toc_aos})

    out_html.write(renderer.render_to_string partial: 'resource', layout: false, :locals => {:record => @resource, :has_children => has_children})

    page_size = 50

    @ordered_records.entries.drop(1).each_slice(page_size) do |entry_set|
      if AppConfig[:pui_pdf_timeout] && AppConfig[:pui_pdf_timeout] > 0 && (Time.now.to_i - start_time.to_i) >= AppConfig[:pui_pdf_timeout]
        raise TimeoutError.new("PDF generation timed out.  Sorry!")
      end

      uri_set = entry_set.map(&:uri).map {|s| s + "#pui"}
      record_set = archivesspace.search_records(uri_set, {}, true).records

      record_set.zip(entry_set).each do |record, entry|
        next unless record.is_a?(ArchivalObject)

        out_html.write(renderer.render_to_string partial: 'archival_object', layout: false, :locals => {:record => record, :level => entry.depth})
      end
    end

    out_html.write(renderer.render_to_string partial: 'footer', layout: false)
    out_html.close

    out_html
  end

  def generate
    out_html = source_file

    # Clean up & in HTML before XML parsing
    html_content = File.read(out_html.path).gsub(/&(?!amp;)(?!quot;)(?!apos;)(?!lt;)(?!gt;)(?!amp;)/, "&amp;")
    File.open(out_html.path, 'w') do |out|
      out << html_content
    end

    XMLCleaner.new.clean(out_html.path)

    pdf_file = Tempfile.new
    pdf_file.close

    converterProperties = com.itextpdf.html2pdf.ConverterProperties.new
    fontProvider = com.itextpdf.html2pdf.resolver.font.DefaultFontProvider.new(false, false, false)
    if AppConfig.has_key?(:pui_pdf_additional_fonts)
      additional_fonts = AppConfig[:pui_pdf_additional_fonts]
      unless additional_fonts.nil?
        additional_fonts.each do |font|
          font_path = File.expand_path("../..", File.dirname(__FILE__)).to_s + '/' + font
          fontProgram = com.itextpdf.io.font.FontProgramFactory.createFont(font_path)
          fontProvider.addFont(fontProgram)
        end
      end
    end
    converterProperties.setFontProvider(fontProvider)

    pdf_output_stream = java.io.FileOutputStream.new(pdf_file.path)
    com.itextpdf.html2pdf.HtmlConverter.convertToPdf(java.io.FileInputStream.new(java.io.File.new(out_html.path)), pdf_output_stream, converterProperties)
    pdf_output_stream.close

    out_html.unlink

    pdf_file
  end
end

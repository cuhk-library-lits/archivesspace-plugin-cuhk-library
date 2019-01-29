class IndexerCommon

    self.add_indexer_initialize_hook do |indexer|
        indexer.add_document_prepare_hook {|doc, record|
            if !doc['title'].nil? && !doc['title'].strip.empty?
                title_sort = doc['title'].gsub(/<[^>]+>/, '')
                title_sort.gsub!(/-/, ' ')
                title_sort.gsub!(/[^\p{Word}\s]/, '')
                title_sort.strip

                if title_sort[0].force_encoding("UTF-8").ascii_only?
                    title_sort = "0" + title_sort
                else
                    title_sort = "1" + title_sort
                end

                doc['title_sort'] = title_sort
            end
        }
    end

end
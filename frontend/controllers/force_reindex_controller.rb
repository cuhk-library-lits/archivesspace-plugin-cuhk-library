class ForceReindexController < ApplicationController

  set_access_control  "view_repository" => [:index]

  @@mutex ||= Mutex.new
  INDEXER_STATE_FOLDERS = [
    File.join(AppConfig[:data_directory], "indexer_state"),
    File.join(AppConfig[:data_directory], "indexer_pui_state")
  ]

  def index
    unless INDEXER_STATE_FOLDERS.nil?
        @@mutex.synchronize do
            INDEXER_STATE_FOLDERS.each do |path|
                next if ! File.directory?(path)

                Dir[path + "/**/*"].each do |file|
                    begin
                        FileUtils.remove_entry_secure(file)
                    rescue
                        Rails.logger.warn("Failed to delete file: #{file}")
                    end
                end
            end
        end
        
        @file_list = []
        INDEXER_STATE_FOLDERS.each do |path|
            begin
                @file_list += Dir[path + "/**/*"] if File.directory?(path)
            rescue
                Rails.logger.warn("Failed to list files in directory: #{path}")
            end
        end
        
        flash.clear
        if @file_list.length == 0
            flash[:success] = "Index state files cleared successfully."
        else
            flash[:error] = "Failed to delete #{@file_list.length} file(s)"
        end

        
    end
  end

end
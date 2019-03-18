class SystemStatusController < ApplicationController

  set_access_control  "view_repository" => [:index, :create]

  @@mutex ||= Mutex.new
  SYS_STATUS_FILE = File.join(AppConfig[:data_directory], "sys_status")
  
  def sys_status_params
    params.require(:sys_status).permit( :success_message, :warning_message, :error_message, :info_message)
  end
 
  def index
    @sys_status = {}
    @sys_status["success_message"] = ""
    @sys_status["warning_message"] = ""
    @sys_status["error_message"] = ""
    @sys_status["info_message"] = ""
    
    if File.file?(SYS_STATUS_FILE)
        begin
            file = File.read(SYS_STATUS_FILE)
            @sys_status = JSON.parse(file)
        rescue
            Rails.logger.warn("Failed to parse sys_status file.")
        end
    end
  end

  def create
    @sys_status = sys_status_params
    @@mutex.synchronize do
        begin
            file = File.new(SYS_STATUS_FILE, 'w')
            file.write(@sys_status.to_json)
        rescue
            Rails.logger.warn("Failed to write to sys_status file.")
        ensure
            file.close unless file.nil?
        end
    end
    render :action => :index
  end

end
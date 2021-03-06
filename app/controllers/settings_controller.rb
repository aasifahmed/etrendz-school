class SettingsController < ApplicationController
  before_action :login_required
  filter_access_to :all

  FILE_EXTENSIONS = [".jpg",".jpeg",".png"]#,".gif",".png"]
  FILE_MAXIMUM_SIZE_FOR_FILE=1048576

  def settings
    @config = Setting.get_multiple_configs_as_hash ['InstitutionName', 'InstitutionAddress', 'InstitutionPhoneNo', \
        'StudentAttendanceType', 'CurrencyType', 'ExamResultType', 'AdmissionNumberAutoIncrement','EmployeeNumberAutoIncrement', \
        'NetworkState','Locale','FinancialYearStartDate','FinancialYearEndDate','EnableNewsCommentModeration','DefaultCountry','TimeZone','FirstTimeLoginEnable']
    @grading_types = Course::GRADINGTYPES
    @enabled_grading_types = Setting.get_grading_types
    @time_zones = TimeZone.all
    @school_detail = SchoolDetail.first || SchoolDetail.new
    @countries=Country.all
    if request.post?
      Setting.set_config_values(params[:setting])
      session[:language] = nil unless session[:language].nil?
      @school_detail.logo = params[:school_detail][:school_logo] if params[:school_detail].present?
      unless @school_detail.save
        @config = Setting.get_multiple_configs_as_hash ['InstitutionName', 'InstitutionAddress', 'InstitutionPhoneNo', \
            'StudentAttendanceType', 'CurrencyType', 'ExamResultType', 'AdmissionNumberAutoIncrement','EmployeeNumberAutoIncrement', \
            'NetworkState','Locale','FinancialYearStartDate','FinancialYearEndDate','EnableNewsCommentModeration','DefaultCountry','TimeZone','FirstTimeLoginEnable']
        return
      end
      @current_user.clear_menu_cache
      Setting.clear_school_cache(@current_user)
      News.new.reload_news_bar
      flash[:notice] = "#{t('flash_msg8')}"
      redirect_to :action => "settings"  and return
    end
  end

  def index

  end
end

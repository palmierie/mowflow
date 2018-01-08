class ApplicationController < ActionController::Base
  @@last_signed_in ||= ""
  protect_from_forgery with: :exception
  before_action :require_login
  # update signed in time if user has a business and the last signed in date is prior to today
  after_action :update_signed_in
  
  private
    def not_authenticated
      redirect_to login_path, alert: "Please login first"
    end

    def update_signed_in
      if current_user != nil
        @user_business = UserBusiness.where('user_id = ?', current_user).first
        if @user_business != nil
          @business = Business.where('id = ?', @user_business.business_id).first
          @last_signed_in_date = @business.signed_in
          # sets previous signed in date to class variable to be accessed by controllers
          # if last signed in date is previous to today, then update signed in date
          if Date.today > @last_signed_in_date||= 0
            get_set_last_signed_in(@last_signed_in_date)
            @business.signed_in = Date.today
            @business.save
          end
        end
      end
    end

    def get_set_last_signed_in(date_to_save = nil)
      @@last_signed_in = date_to_save || @@last_signed_in
      return @@last_signed_in
    end

end

class PagesController < ApplicationController
  skip_before_action :require_login, only: [:home]
  def home
    
  end
  def dashboard
    @user_business = UserBusiness.where('user_id = ?', current_user)
    if current_user.user_businesses == nil?
      redirect_to new_business_path
    end

    
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    
    # Never trust parameters from the scary internet, only allow the white list through.
    
end

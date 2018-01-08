class UserBusinessesController < ApplicationController
  
  def new
    @business = Business.find(params[:id])
    @user_business = UserBusiness.new({business: business})
  end

  def create
    @business = Business.find(params[:id])
    @user_business = UserBusiness.new(user_business_params)
  end

  # def edit
  #   @business = Business.find(params[:id])
  #   puts "log user_biz: #{@business}"
  # end

  # def update
  #   @user_business = set_user_business
  #   @user_business.update
  # end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_user_business
      @user_business = UserBusiness.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_business_params
      params.require(:user_business).permit(:user_id, :business_id)
    end
end
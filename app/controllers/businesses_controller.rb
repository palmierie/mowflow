class BusinessesController < ApplicationController

  def new
    @business = Business.new
    @business.user_businesses.build
  end

  def create
    @business = Business.new(business_params)
    respond_to do |format|
      if @business.save
        format.html { redirect_to dashboard_path, notice: 'Business was successfully created.' }
        # format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @business.errors, status: :unprocessable_entity }
      end
    end
  end
  

  private
    # Use callbacks to share common setup or constraints between actions.
    
    # Never trust parameters from the scary internet, only allow the white list through.
   
    def business_params
      params.require(:business).permit(:name, :user_id, :password, :password_confirmation,
                                      user_businesses_attributes:[:user_id, :business_id])
    end
end

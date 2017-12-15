class ClientsController < ApplicationController

  def index
    @clients = Client.all
  end

  def new
    @client = Client.new
    @business = get_business
  end

  def create
    @business = get_business
    @client = Client.new(client_params)
    @client.business_id = @business.id
    respond_to do |format|
      if @client.save
        format.html { redirect_to dashboard_path, notice: 'Client was successfully created.' }
        # format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @client = Client.find(params[:id])
  end

  def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      redirect_to show
    else
      render 'edit'
    end
  end



  private
  
    # Use callbacks to share common setup or constraints between actions.
    
    def get_business
      @user_business = UserBusiness.where('user_id = ?', current_user).first
      @business = Business.where('id = ?', @user_business.business_id).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:business_id, :full_name, :second_full_name, :email, :second_email, :phone, :second_phone, :additional_note)
    end
end
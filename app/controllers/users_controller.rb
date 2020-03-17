class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.nickname ||= @user.user_id
    if @user.save
      # render json: @user, status: :created, location: @user
      render status: 200, json: {
                      "message": "Account successfully created",
                      "user": {
                        "user_id": @user.user_id,
                        "nickname": @user.nickname
                      }
                    }
    else
      # render json: @user.errors, status: :unprocessable_entity
      render status: 400, json: {
                      "message": "Account creation failed",
                      "cause": @user.errors.messages
                    }
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:user_id, :password, :nickname, :comment)
    end
end

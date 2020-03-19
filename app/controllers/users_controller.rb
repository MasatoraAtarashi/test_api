class UsersController < ApplicationController
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods
  before_action :set_user, only: [:show, :update]
  before_action :set_user_for_close, only: :destroy

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    if !(@user.comment.nil?)
      render json: {
        "message": "User details by user_id",
        "user": {
          "user_id": @user.user_id,
          "nickname": @user.nickname,
          "comment": @user.comment
        }
      }
    else
      render json: {
        "message": "User details by user_id",
        "user": {
          "user_id": @user.user_id,
          "nickname": @user.nickname,
        }
      }
    end
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
    render status: 200, json: { "message": "Account and user successfully removed" }
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by(user_id: params[:user_id])
      if @user
        http_basic_authenticate
      else
        render status: 404, json: { message: 'No User found' }
      end
    end

    def set_user_for_close
      authenticate_or_request_with_http_basic do |username, password|
        @user = User.find_by(user_id: username)
        if @user
          password == @user.password ? true : render_unauthorized
        else
          render status: 404, json: { message: 'No User found' }
        end
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:user_id, :password, :nickname, :comment)
    end

    def http_basic_authenticate
      authenticate_or_request_with_http_basic do |username, password|
        if username == @user.user_id && password == @user.password
          true
        else
          render_unauthorized
        end
      end
    end


    def render_unauthorized
      # render_errors(:unauthorized, ['invalid token'])
      obj = { message: 'Authentication Faild' }
      render status: 401, json: obj
    end
end

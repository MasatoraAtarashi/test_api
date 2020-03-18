require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  before do
    perfect_params = {'user_id': 'TaroYamada', 'password': 'PaSSwd4TY', 'nickname': 'たろー', 'comment': '僕は元気です'}
    post '/signup', params: { user: perfect_params }

    valid_params = {'user_id': 'masatora', 'password': 'password'}
    post '/signup', params: { user: valid_params }
  end

  describe 'POST /signup' do
    it 'userを作成する' do
      valid_params = {'user_id': 'userid', 'password': 'password'}
      expect { post '/signup', params: { user: valid_params } }.to change(User, :count).by(+1)
      expect(response.status).to eq(200)
    end

    context 'userを作成する(エラー)' do
      it 'requiredエラー' do
        invalid_params = {'user_id': '', 'password': ''}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
        # expect(response.body.cause).to eq('required user_id and password')
      end

      it 'lengthエラー(user_id短い)' do
        invalid_params = {'user_id': 'user', 'password': 'password'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
        # expect(response.body.cause).to eq('user_id should be more than 6 characters')
      end

      it 'lengthエラー(user_id長い)' do
        invalid_params = {'user_id': 'u' * 21, 'password': 'password'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'lengthエラー(password短い)' do
        invalid_params = {'user_id': 'userid', 'password': 'passwor'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'lengthエラー(password長い)' do
        invalid_params = {'user_id': 'userid', 'password': 'p' * 21}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'pattern正常(user_idに英数字,passwordに英数字記号)' do
        valid_params = {'user_id': 'userid3', 'password': 'password-{@}'}
        expect { post '/signup', params: { user: valid_params } }.to change(User, :count).by(+1)
        expect(response.status).to eq(200)
      end

      it 'patternエラー(user_idに記号)' do
        invalid_params = {'user_id': 'userid-:', 'password': 'password'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end

      it 'patternエラー(passwordに空白文字)' do
        invalid_params = {'user_id': 'userid', 'password': 'passwor d'}
        expect { post '/signup', params: { user: invalid_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
      end


      it '既に同じuser_idを持つアカウントが存在している場合' do
        valid_params = {'user_id': 'userid', 'password': 'password'}
        dup_params = {'user_id': 'userid', 'password': 'password'}
        post '/signup', params: { user: valid_params }
        expect { post '/signup', params: { user: dup_params } }.to change(User, :count).by(+0)
        expect(response.status).to eq(400)
        # expect(response.body.cause).to eq('already same user_id is used')
      end
    end
  end

  describe 'GET /users/{user_id}' do
    it 'ユーザー情報を取得する(全部情報ある版)' do
      get '/users/TaroYamada', headers: { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials("TaroYamada","PaSSwd4TY") }
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expected = {
        "message": "User details by user_id",
        "user": {
          "user_id": "TaroYamada",
          "nickname": "たろー",
          "comment": "僕は元気です"
          }
      }.to_json
      response.body.should == expected
    end

    it 'ユーザー情報を取得する(nicknameとcommentない版)' do
      get '/users/masatora', headers: { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials("masatora","password") }
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expected = {
        "message": "User details by user_id",
        "user": {
          "user_id": "masatora",
          "nickname": "masatora"
          }
      }.to_json
      response.body.should == expected
    end

    it '指定user_idのユーザ情報が存在しない場合' do
      get '/users/anonymass', headers: { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials("anonymass","password") }
      json = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expected = { "message": "No User found" }.to_json
      response.body.should == expected
    end

    it 'Authorizationヘッダでの認証が失敗した場合' do
      get '/users/TaroYamada', headers: { 'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials("TaroYamada","password") }
      json = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expected = { "message": "Authentication Faild" }.to_json
      response.body.should == expected
    end
  end

  describe 'PATCH /users/{user_id}' do
    it '成功' do
    end

    it '指定user_idのユーザ情報が存在しない場合' do
    end

    it 'nickname と comment が両方とも指定されていない場合' do
    end

    it 'user_id や password を変更しようとしている場合' do
    end

    it 'Authorizationヘッダでの認証が失敗した場合' do
    end

    it '認証と異なるIDのユーザを指定した場合' do
    end

    it 'nickname30文字以上指定した場合' do
    end

    it 'nickname空文字' do
    end

    it 'comment100文字以上指定した場合' do
    end

    it 'comment空文字' do
    end
  end

  describe 'POST /close' do
  end
end

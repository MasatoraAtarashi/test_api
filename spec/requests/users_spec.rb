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
      get '/users/TaroYamada', Authorization: {"user_id": "TaroYamada", "password": "PaSSwd4TY"}
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(response.body).to eq({
                                  "message": "User details by user_id",
                                  "user": {
                                    "user_id": "TaroYamada",
                                    "nickname": "たろー",
                                    "comment": "僕は元気です"
                                    }
                                  })
    end

    it 'ユーザー情報を取得する(nicknameとcommentない版)' do
      get '/users/masatora', Authorization: {"user_id": "masatora", "password": "password"}
      json = JSON.parse(response.body)
      expect(response.status).to eq(200)
      expect(response.body).to eq({
                                  "message": "User details by user_id",
                                  "user": {
                                    "user_id": "masatora",
                                    "nickname": "masatora"
                                    }
                                  })
    end

    it '指定user_idのユーザ情報が存在しない場合' do
      get '/users/anonymass', Authorization: {"user_id": "anonymass", "password": "password"}
      json = JSON.parse(response.body)
      expect(response.status).to eq(404)
      expect(response.body).to eq({ "message":"No User found" })
    end

    it 'Authorizationヘッダでの認証が失敗した場合' do
      get '/users/masatora', Authorization: {"user_id": "masatora", "password": "passunko"}
      json = JSON.parse(response.body)
      expect(response.status).to eq(401)
      expect(response.body).to eq({ "message":"Authentication Faild" })
    end
  end

  describe 'PATCH /users/{user_id}' do
  end

  describe 'POST /close' do
  end
end

require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "Benutzerliste ist nicht öffentlich erreichbar" do
    get "/users"
    assert_response :not_found
  end

  test "new" do
    get new_user_path
    assert_response :success
  end

  test "create als creator" do
    assert_difference -> { User.count }, +1 do
      post users_path, params: { user: {
        username: "neu", email_address: "neu@example.com", role: "creator", password: "geheim123"
      } }
    end
    assert_redirected_to root_path
    assert User.find_by(username: "neu").creator?
    assert cookies[:session_id].present?
  end

  test "create kann sich nicht selbst zum admin machen" do
    post users_path, params: { user: {
      username: "neu", email_address: "neu@example.com", password: "geheim123", admin: true
    } }
    assert_not User.find_by(username: "neu").admin?
  end

  test "create mit doppelter E-Mail schlägt fehl" do
    assert_no_difference -> { User.count } do
      post users_path, params: { user: {
        username: "neu", email_address: users(:user).email_address, password: "geheim123"
      } }
    end
    assert_response :unprocessable_entity
  end

  test "create ohne Passwort schlägt fehl" do
    assert_no_difference -> { User.count } do
      post users_path, params: { user: { username: "neu", email_address: "neu@example.com" } }
    end
    assert_response :unprocessable_entity
  end
end

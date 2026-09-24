require "test_helper"

class AuthenticationTest < ActionDispatch::IntegrationTest
  test "Login mit unbekanntem Benutzernamen" do
    post session_path, params: { username: "gibtsnicht", password: "password" }
    assert_redirected_to new_session_path
    assert cookies[:session_id].blank?
  end

  test "Registrierung mit bereits vergebenem Benutzernamen schlägt fehl" do
    assert_no_difference -> { User.count } do
      post users_path, params: { user: {
        username: users(:user).username, email_address: "anders@example.com", password: "geheim123"
      } }
    end
    assert_response :unprocessable_entity
  end
end

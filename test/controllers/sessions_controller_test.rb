require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create mit richtigen Daten" do
    log_in_as users(:user)
    assert_redirected_to root_path
    assert cookies[:session_id].present?
  end

  test "create mit falschem Passwort" do
    log_in_as users(:user), password: "falsch"
    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as users(:user)
    delete session_path
    assert_redirected_to new_session_path
    assert_empty cookies[:session_id]
  end

  test "destroy als Gast leitet zum Login" do
    assert_no_difference -> { Session.count } do
      delete session_path
    end
    assert_redirected_to new_session_path
  end
end

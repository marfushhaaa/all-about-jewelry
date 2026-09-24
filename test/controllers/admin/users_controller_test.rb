require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "index als admin zeigt Benutzer und Protokoll" do
    log_in_as users(:admin)
    get admin_users_path
    assert_response :success
    assert_select "td", text: users(:creator).username
  end

  test "index als Nicht-Admin wird verweigert" do
    log_in_as users(:creator)
    get admin_users_path
    assert_redirected_to root_path
  end

  test "index als Gast leitet zum Login" do
    get admin_users_path
    assert_redirected_to new_session_path
  end

  test "destroy als admin löscht Benutzer samt Kursen und Buchungen" do
    log_in_as users(:admin)
    assert_difference -> { User.count } => -1, -> { Course.count } => -1 do
      delete admin_user_path(users(:creator_two))
    end
    assert_redirected_to admin_users_path
    assert_equal "Benutzer gelöscht.", flash[:notice]
  end

  test "admin kann sich nicht selbst löschen" do
    log_in_as users(:admin)
    assert_no_difference -> { User.count } do
      delete admin_user_path(users(:admin))
    end
    assert_redirected_to root_path
  end

  test "destroy als Nicht-Admin wird verweigert" do
    log_in_as users(:creator)
    assert_no_difference -> { User.count } do
      delete admin_user_path(users(:user))
    end
    assert_redirected_to root_path
  end

  test "destroy als Gast leitet zum Login" do
    assert_no_difference -> { User.count } do
      delete admin_user_path(users(:user))
    end
    assert_redirected_to new_session_path
  end
end

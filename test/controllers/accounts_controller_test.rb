require "test_helper"

class AccountsControllerTest < ActionDispatch::IntegrationTest
  test "show als Gast leitet zum Login" do
    get account_path
    assert_redirected_to new_session_path
  end

  test "show zeigt eigene bestätigte Buchungen, nicht die stornierten" do
    log_in_as users(:user)
    get account_path
    assert_response :success
    assert_select "a", text: bookings(:confirmed).course.name
    assert_select "a", text: bookings(:cancelled).course.name, count: 0
  end

  test "show zeigt creator seine Kurse" do
    log_in_as users(:creator)
    get account_path
    assert_response :success
    assert_select "h2", text: "Meine Kurse"
    assert_select "a", text: courses(:creator_course).name
  end

  test "show zeigt user keine Kursverwaltung" do
    log_in_as users(:user)
    get account_path
    assert_select "h2", text: "Meine Kurse", count: 0
  end

  test "edit" do
    log_in_as users(:user)
    get edit_account_path
    assert_response :success
  end

  test "edit als Gast leitet zum Login" do
    get edit_account_path
    assert_redirected_to new_session_path
  end

  test "update ändert eigenes Profil" do
    log_in_as users(:user)
    patch account_path, params: { user: { username: "neuer_name", email_address: "neu@example.com" } }
    assert_redirected_to account_path
    assert_equal "neuer_name", users(:user).reload.username
  end

  test "update mit ungültigen Daten" do
    log_in_as users(:user)
    patch account_path, params: { user: { username: "" } }
    assert_response :unprocessable_entity
    assert_equal "user", users(:user).reload.username
  end

  test "update ignoriert role und admin" do
    log_in_as users(:user)
    patch account_path, params: { user: { role: "creator", admin: true } }
    users(:user).reload
    assert users(:user).user?
    assert_not users(:user).admin?
  end

  test "update als Gast leitet zum Login" do
    patch account_path, params: { user: { username: "x" } }
    assert_redirected_to new_session_path
  end
end

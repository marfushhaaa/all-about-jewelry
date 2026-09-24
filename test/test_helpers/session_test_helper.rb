module SessionTestHelper
  # Loggt über das echte Login-Formular ein (POST /session).
  def log_in_as(user, password: "password")
    post session_path, params: { username: user.username, password: password }
  end

  def sign_in_as(user)
    Current.session = user.sessions.create!

    ActionDispatch::TestRequest.create.cookie_jar.tap do |cookie_jar|
      cookie_jar.signed[:session_id] = Current.session.id
      cookies["session_id"] = cookie_jar[:session_id]
    end
  end

  def sign_out
    Current.session&.destroy!
    cookies.delete("session_id")
  end
end

ActiveSupport.on_load(:action_dispatch_integration_test) do
  include SessionTestHelper
end

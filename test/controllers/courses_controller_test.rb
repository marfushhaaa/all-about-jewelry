require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:creator_course)
    @valid_params = { course: {
      name: "Neuer Kurs", description: "Beschreibung",
      start_date: 5.days.from_now, end_date: 6.days.from_now, max_participants: 4
    } }
  end

  # index / show – auch für Gäste
  test "index als Gast" do
    get courses_path
    assert_response :success
    assert_select "h2", text: @course.name
  end

  test "root zeigt Kursliste" do
    get root_path
    assert_response :success
  end

  test "index als eingeloggter Benutzer begrüßt ihn" do
    log_in_as users(:user)
    get courses_path
    assert_response :success
    assert_select "h1", text: "Willkommen zurück, user"
  end

  test "show als Gast zeigt Login-Link statt Buchen" do
    get course_path(@course)
    assert_response :success
    assert_select "h1", text: @course.name
    assert_select "a[href=?]", new_session_path, text: "Zum Buchen anmelden"
  end

  test "show zeigt Buchen-Link für buchbaren Kurs" do
    log_in_as users(:user)
    get course_path(courses(:last_place_course))
    assert_select "a[href=?]", new_course_booking_path(courses(:last_place_course))
  end

  test "show zeigt ausgebucht" do
    log_in_as users(:user)
    get course_path(courses(:full_course))
    assert_select "p", text: "Dieser Kurs ist ausgebucht."
  end

  test "show zeigt Bearbeiten nur dem Besitzer" do
    log_in_as users(:creator)
    get course_path(@course)
    assert_select "a[href=?]", edit_course_path(@course)

    delete session_path
    log_in_as users(:creator_two)
    get course_path(@course)
    assert_select "a[href=?]", edit_course_path(@course), count: 0
  end

  test "show mit unbekannter ID liefert 404" do
    get course_path(id: 0)
    assert_response :not_found
  end

  # new / create
  test "new als creator" do
    log_in_as users(:creator)
    get new_course_path
    assert_response :success
  end

  test "new als user wird verweigert" do
    log_in_as users(:user)
    get new_course_path
    assert_redirected_to root_path
  end

  test "new als Gast leitet zum Login" do
    get new_course_path
    assert_redirected_to new_session_path
  end

  test "create als creator legt Kurs an" do
    log_in_as users(:creator)
    assert_difference -> { Course.count }, +1 do
      post courses_path, params: @valid_params
    end
    course = Course.last
    assert_redirected_to course_path(course)
    assert_equal users(:creator), course.creator
    assert_equal "Kurs erstellt.", flash[:notice]
  end

  test "create als admin legt Kurs an" do
    log_in_as users(:admin)
    assert_difference -> { Course.count }, +1 do
      post courses_path, params: @valid_params
    end
  end

  test "create mit ungültigen Daten rendert Formular" do
    log_in_as users(:creator)
    assert_no_difference -> { Course.count } do
      post courses_path, params: { course: { name: "", start_date: 5.days.from_now, end_date: 4.days.from_now } }
    end
    assert_response :unprocessable_entity
  end

  test "create ignoriert creator_id aus den Parametern" do
    log_in_as users(:creator)
    post courses_path, params: { course: @valid_params[:course].merge(creator_id: users(:creator_two).id) }
    assert_equal users(:creator), Course.last.creator
  end

  test "create als user wird verweigert" do
    log_in_as users(:user)
    assert_no_difference -> { Course.count } do
      post courses_path, params: @valid_params
    end
    assert_redirected_to root_path
  end

  test "create als Gast leitet zum Login" do
    assert_no_difference -> { Course.count } do
      post courses_path, params: @valid_params
    end
    assert_redirected_to new_session_path
  end

  # edit / update
  test "edit als Besitzer" do
    log_in_as users(:creator)
    get edit_course_path(@course)
    assert_response :success
  end

  test "edit als fremder creator wird verweigert" do
    log_in_as users(:creator_two)
    get edit_course_path(@course)
    assert_redirected_to root_path
  end

  test "update als Besitzer" do
    log_in_as users(:creator)
    patch course_path(@course), params: { course: { name: "Umbenannt" } }
    assert_redirected_to course_path(@course)
    assert_equal "Umbenannt", @course.reload.name
  end

  test "update als admin auf fremden Kurs" do
    log_in_as users(:admin)
    patch course_path(@course), params: { course: { name: "Vom Admin" } }
    assert_redirected_to course_path(@course)
    assert_equal "Vom Admin", @course.reload.name
  end

  test "update mit ungültigen Daten" do
    log_in_as users(:creator)
    patch course_path(@course), params: { course: { end_date: @course.start_date - 1.day } }
    assert_response :unprocessable_entity
  end

  test "update als fremder creator wird verweigert" do
    log_in_as users(:creator_two)
    assert_no_changes -> { @course.reload.name } do
      patch course_path(@course), params: { course: { name: "Gehackt" } }
    end
    assert_redirected_to root_path
  end

  # destroy
  test "destroy als Besitzer löscht Kurs samt Buchungen" do
    log_in_as users(:creator)
    course = courses(:open_course)
    assert_difference -> { Course.count } => -1, -> { Booking.count } => -1 do
      delete course_path(course)
    end
    assert_redirected_to courses_path
  end

  test "destroy als admin" do
    log_in_as users(:admin)
    assert_difference -> { Course.count }, -1 do
      delete course_path(@course)
    end
  end

  test "destroy als fremder creator wird verweigert" do
    log_in_as users(:creator_two)
    assert_no_difference -> { Course.count } do
      delete course_path(@course)
    end
    assert_redirected_to root_path
  end
end

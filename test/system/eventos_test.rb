require "application_system_test_case"

class EventosTest < ApplicationSystemTestCase
  setup do
    @evento = eventos(:one)
  end

  test "visiting the index" do
    visit eventos_url
    assert_selector "h1", text: "Eventos"
  end

  test "should create evento" do
    visit eventos_url
    click_on "New evento"

    fill_in "Eve data", with: @evento.EVE_DATA
    fill_in "Eve desc", with: @evento.EVE_DESC
    fill_in "Eve local", with: @evento.EVE_LOCAL
    fill_in "Eve nome", with: @evento.EVE_NOME
    click_on "Create Evento"

    assert_text "Evento was successfully created"
    click_on "Back"
  end

  test "should update Evento" do
    visit evento_url(@evento)
    click_on "Edit this evento", match: :first

    fill_in "Eve data", with: @evento.EVE_DATA.to_s
    fill_in "Eve desc", with: @evento.EVE_DESC
    fill_in "Eve local", with: @evento.EVE_LOCAL
    fill_in "Eve nome", with: @evento.EVE_NOME
    click_on "Update Evento"

    assert_text "Evento was successfully updated"
    click_on "Back"
  end

  test "should destroy Evento" do
    visit evento_url(@evento)
    accept_confirm { click_on "Destroy this evento", match: :first }

    assert_text "Evento was successfully destroyed"
  end
end

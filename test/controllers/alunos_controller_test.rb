require "test_helper"

class AlunosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get alunos_index_url
    assert_response :success
  end

  test "should get show" do
    get alunos_show_url
    assert_response :success
  end

  test "should get new" do
    get alunos_new_url
    assert_response :success
  end

  test "should get create" do
    get alunos_create_url
    assert_response :success
  end

  test "should get edit" do
    get alunos_edit_url
    assert_response :success
  end

  test "should get update" do
    get alunos_update_url
    assert_response :success
  end

  test "should get destroy" do
    get alunos_destroy_url
    assert_response :success
  end
end

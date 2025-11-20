require "test_helper"

class PagamentosControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get pagamentos_index_url
    assert_response :success
  end

  test "should get new" do
    get pagamentos_new_url
    assert_response :success
  end

  test "should get create" do
    get pagamentos_create_url
    assert_response :success
  end

  test "should get edit" do
    get pagamentos_edit_url
    assert_response :success
  end

  test "should get update" do
    get pagamentos_update_url
    assert_response :success
  end

  test "should get destroy" do
    get pagamentos_destroy_url
    assert_response :success
  end
end

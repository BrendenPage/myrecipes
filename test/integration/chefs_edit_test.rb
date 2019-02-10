require 'test_helper'

class ChefsEditTest < ActionDispatch::IntegrationTest
  def setup
    @chef = Chef.create!(chefname: "mashpot", email: "mashpot@potatoes.com",password: "password", password_confirmation: "password")
    @chef2= Chef.create!(chefname:"mashrur",email:"mashrur.hossain@gmail.com",password:"password",password_confirmation:"password")
    @admin_user= Chef.create!(chefname:"admin",email:"admin@gmail.com",password:"password",password_confirmation:"password", admin: true)
    @recipe = Recipe.create(name: "vag sauce", description: "great vage", chef: @chef)
    @recipe2 = @chef.recipes.build(name: "chicken sute", description: "great chicken dish")
    @recipe2.save
  end
  
  test "reject an invalid edit" do
    sign_in_as(@chef,"password")
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: {chef: {chefname: " ", email: "brendenpage@gmail.com"}}
    assert_template 'chefs/edit'
    assert_select 'h2.panel-title'
    assert_select 'div.panel-body'
  end
  
  test "accept a valid edit" do
    sign_in_as(@chef,"password")
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: {chef: {chefname: "brenden1", email: "brendenpage1@gmail.com"}}
    assert_redirected_to @chef
    assert_not flash.empty?
    @chef.reload
    assert_match "brenden1", @chef.chefname
    assert_match "brendenpage1@gmail.com", @chef.email
  end
  
  test "accept edit attempt by admin user" do
    sign_in_as(@admin_user, "password")
    get edit_chef_path(@chef)
    assert_template 'chefs/edit'
    patch chef_path(@chef), params: {chef: {chefname: "brenden3", email: "brendenpage3@gmail.com"}}
    assert_redirected_to @chef
    assert_not flash.empty?
    @chef.reload
    assert_match "brenden3", @chef.chefname
    assert_match "brendenpage3@gmail.com", @chef.email
  end
  
  test "redirect edit attempt by another non-admin user" do
    sign_in_as(@chef2, "password")
    updated_name = "joe"
    updated_email = "joe@example.com"
    patch chef_path(@chef), params: {chef: {chefname: updated_name, email: updated_email}}
    assert_redirected_to chefs_path
    assert_not flash.empty?
    @chef.reload
    assert_match "mashpot", @chef.chefname
    assert_match "mashpot@potatoes.com", @chef.email
  end
end

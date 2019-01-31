require 'test_helper'

class RecipesDeleteTest < ActionDispatch::IntegrationTest
  def setup
    @chef = Chef.create!(chefname: "mashpot", email: "mashpot@potatoes.com",password: "password", password_confirmation: "password")
    @recipe = Recipe.create(name: "vag sauce", description: "great vage", chef: @chef)
    @recipe2 = @chef.recipes.build(name: "chicken sute", description: "great chicken dish")
    @recipe2.save
  end
  
  test "successfully delete a recipe" do
    sign_in_as(@chef,"password")
    get recipe_path(@recipe)
    assert_template 'recipes/show'
    assert_select 'a[href=?]', recipe_path(@recipe), text: "Delete this recipe"
    assert_difference 'Recipe.count', -1 do
      delete recipe_path(@recipe)
    end
    assert_redirected_to recipes_path
    assert_not flash.empty?
  end
end

# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on "turbolinks:load", ->
  $(".dropdown-menu li").click ->
    selText = $(this).text()
    selValue = $(this).attr("value")
    $(this).parents().find('.dropdown-toggle').html(selText+' <span class="caret"></span>')
    $("#category").attr("value",selValue)

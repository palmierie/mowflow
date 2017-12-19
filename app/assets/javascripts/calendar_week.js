document.addEventListener("turbolinks:load",function () {
  
  // $("#jobs").sortable();

  $(".connected-list").sortable({
    connectWith: '.connected-list',
    update: function (e, ui) {
      console.log($(this).attr("data-date"));
      console.log($(this).sortable('serialize'));
      
      Rails.ajax({
        url: $(this).data("url") + "?date=" + $(this).attr("data-date"),
        type: "PATCH",
        data: $(this).sortable('serialize')
      })
    }
    
  });
});
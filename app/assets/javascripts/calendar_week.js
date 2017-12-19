document.addEventListener("turbolinks:load",function () {
  
  // $("#jobs").sortable();

  $(".connected-list").sortable({
    connectWith: '.connected-list',
    update: function (e, ui) {
      console.log($(this).attr("data-date"));
      console.log($(this).sortable('serialize'));
      
      Rails.ajax({
        url: $(this).data("url"),
        type: "PATCH",
        data: {
          data_1: $(this).sortable('serialize'),
          data_2: $(this).attr("data-date")
        }
      })
    }
    
  });
});
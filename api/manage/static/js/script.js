function showTab(tabId)
{
    var list = ['op', 'crypt', 'userinfo', 'home', 'genkey', 'expr', 'file'];

    for (var i = 0; i < list.length; i++)
    {
        $('#' + list[i]).addClass("hide");
        $('#' + list[i] + '-nav').removeClass("active");
    }


    $('#' + tabId).removeClass("hide");
    $('#' + tabId + '-nav').addClass("active");
}

function logout()
{

    $.ajax({
        type: "GET",
        url: $(location).attr('href'),
        data: {logout: "logout"}
    });


    location.reload();
}

$(document).ready(function()
{
    $('[data-toggle="tooltip"]').tooltip();

    var id = window.location.href.split('/#/').pop();

    try {
        if (id != 'logout')
            $('#' + id + '-nav').click();

    }
    catch(error) {
        //console.error(error);
    }
});
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

    <title>Homomorphic encryption over elliptic curve</title>


    <!-- JQuery -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

    <!-- Notification-->
    <script src="https://rawgit.com/notifyjs/notifyjs/master/dist/notify.js" type="text/javascript"></script>

    <!-- PDF Object
    <script src="https://bgn.rainteam.xyz/static/js/pdfobject.min.js" type="text/javascript"></script>-->

    <!-- Font Awesome 4 -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">



    {literal}
    <style type="text/css">
        ::-webkit-scrollbar {
            width: 0px;
        }

        .navbar {
            position: sticky;
            z-index: 100;
            top: 0;
        }


    </style>

    <!-- Custom script -->
    <!--<script src="static/js/script.js"></script>-->

    <script src="static/js/file-upload.js"></script>
    <link rel="stylesheet" href="static/css/file-upload.css"/>


    <script type="text/javascript">
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

            $('.file-upload').file_upload();
        });
    </script>
    {/literal}

    <link rel="stylesheet" href="static/css/index.css">
</head>
<body>

<nav class="navbar navbar-default">
    <div class="container">
        <div class="navbar-header">
            <a class="navbar-brand" href="/">Homomorphic encryption</a>
        </div>
        <ul class="nav navbar-nav" role="tablist">
            <li id="home-nav" data-toggle="tooltip" data-placement="bottom" title="Home" onclick="showTab('home')"><a href="#/home"><span class="fa fa-home fa-2x"></span> Home</a></li>
            <li id="genkey-nav" data-toggle="tooltip" data-placement="bottom" title="Generate key pairs" onclick="showTab('genkey')"><a href="#/genkey"><span class="fa fa-key fa-2x"></span> Make keys</a></li>
            <li id="crypt-nav" data-toggle="tooltip" data-placement="bottom" title="Crypt" onclick="showTab('crypt')"><a href="#/crypt"><span class="fa fa-lock fa-2x"></span> Crypt</a></li>
            <li id="op-nav" data-toggle="tooltip" data-placement="bottom" title="Operations" onclick="showTab('op')"><a href="#/op"><span class="fa fa-calculator fa-2x"></span> Operations</a></li>
            <li id="expr-nav" data-toggle="tooltip" data-placement="bottom" title="Expression" onclick="showTab('expr')"><a href="#/expr"><span class="fa fa-calculator fa-2x"></span> Expression</a></li>
            <li id="file-nav" data-toggle="tooltip" data-placement="bottom" title="File" onclick="showTab('file')"><a href="#/file"><span class="fa fa-file fa-2x"></span> File</a></li>
            <li data-toggle="tooltip" data-placement="bottom" title="Github"><a href="https://github.com/baonq-me/bgn" target="_blank"><span class="fa fa-github fa-2x"></span> Source code</a></li>

        </ul>

        <ul class="nav navbar-nav navbar-right">
            <li class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="/"><span class="fa fa-user fa-2x"></span> User
                    <span class="caret"></span></a>
                <ul class="dropdown-menu">
                    <li id="userinfo-nav" data-toggle="tooltip" data-placement="left" title="User Information" onclick="showTab('userinfo')"><a href="#/userinfo"><span class="fa fa-info-circle"></span> Infomation</a></li>
                    <li id="logout-nav" data-toggle="tooltip" data-placement="left" title="Logout" onclick="logout()"><a href="#/logout"><span class="fa fa-sign-out"></span> Logout</a></li>
                    <li>
                        <iframe width="219" height="302" src="https://www.calculator-1.com/outdoor/" scrolling="no" frameborder="0"></iframe>
                    </li>
                </ul>
            </li>
        </ul>
    </div>
</nav>

<div id="home" class="container">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="fa fa-home"></span> Somewhat homomorphic encryption over elliptic curve using BGN algorithm
            </h1>
        </div>
        <div class="panel-body">
            <object data="https://bgn.rainteam.xyz/static/pdf/bgn.pdf" type="application/pdf" width="100%" height="500px">
                <p><b>Homomorphic Encryption and the BGN Cryptosystem</b>: This browser does not support PDFs. Please download the PDF to view it: <a href="https://code.rainteam.xyz/static/pdf/bgn.pdf">Download PDF</a>.</p>
            </object>
        </div>
    </div>
</div>

{literal}
    <script type="text/javascript">
        function crypt()
        {
            $.notify("Please wait ...", "warn");

            var key = $("#crypt .panel-default .panel-body div .key").val();
            var data = $("#crypt .panel-default .panel-body div .data").val();
            var op = $("#crypt .panel-default .panel-body div label input[name=op]:checked").val();

            $.ajax({
                type: "POST",
                url: "https://bgn.rainteam.xyz/api/crypt",
                timeout: 120000,      // Timeout 5000ms
                data: JSON.stringify({key: key, data: data, op: op}),
                dataType: "json",
                success: function(data) {
                    console.log(data);

                    if (data['status'] == 'success')
                    {
                        $("#crypt .panel-default .panel-footer div .data").val(data['data']);
                        $.notify("Operation finished in " + data['time'] + "s ", "success");
                    } else 
                    {
                        $.notify(data['msg'], "error");
                    }
                },
                error: function(x, t, m) {
                    $.notify(console.log(x.responseText), "error");
                }
            });
        }
    </script>
{/literal}
<div id="crypt" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="fa fa-lock"></span> Crypt
            </h1>
        </div>

        <div class="panel-body">
            <div class="form-group">
                <label for="">Working mode</label>
                <br/>
                <label class="radio-inline"><input type="radio" name="op" value="encrypt">Encryption</label>
                <label class="radio-inline"><input type="radio" name="op" value="decrypt">Decryption</label>
            </div>

            <div class="form-group">
                <label for="">Key (depend on working mode)</label>
                <textarea class="form-control key" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Data (depend on working mode)</label>
                <textarea class="form-control data" rows="5"></textarea>
            </div>

            <button class="btn btn-success" style="float: right;" onclick="crypt()">Start !</button>
        </div>

        <div class="panel-footer">
            <div class="form-group">
                <label for="">Result</label>
                <textarea class="form-control data" rows="5"></textarea>
            </div>
        </div>
    </div>
</div>


{literal}
<script type="text/javascript">
    function genkey()
    {
        $.notify("Please wait ...", "warn");

        var length = $("#genkey .panel-default .panel-body div .length").val();
        console.log(length);

        $.ajax({
            type: "POST",
            url: "https://bgn.rainteam.xyz/api/genkey",
            timeout: 120000,      // Timeout 5000ms
            data: JSON.stringify({length: length}),
            dataType: "json",
            success: function(data) {
                console.log(data);

                if (data['status'] == 'success')
                {
                    $("#genkey .panel-default .panel-footer div .pkey").val(data['pkey']);
                    $("#genkey .panel-default .panel-footer div .skey").val(data['skey']);

                    $.notify("Operation finished in " + data['time'] + "s ", "success");
                } else 
                {
                    $.notify(data['msg'], "error");
                }
            },
            error: function(x, t, m) {
                $.notify(console.log(x.responseText), "error");
            }
        });
    }
</script>
{/literal}
<div id="genkey" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="fa fa-key"></span> Generate key pairs
            </h1>
        </div>

        <div class="panel-body">
            <div class="form-group">
                <label for="">Key length (min: 32; default: 512; recommended: 1024)</label>
                <input type="text" class="form-control length" />
            </div>
            <button class="btn btn-success" style="float: right;" onclick="genkey()">Start !</button>
        </div>

        <div class="panel-footer">
            <div class="form-group">
                <label for="">Public key</label>
                <textarea class="form-control pkey" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Private key</label>
                <textarea class="form-control skey" rows="5"></textarea>
            </div>
        </div>
    </div>
</div>


{literal}
    <script type="text/javascript">
        function operation()
        {
            $.notify("Please wait ...", "warn");

            var key = $("#op .panel-default .panel-body div .key").val();
            var data1 = $("#op .panel-default .panel-body div .data1").val();
            var data2 = $("#op .panel-default .panel-body div .data2").val();
            var op = $("#op .panel-default .panel-body div label input[name=op]:checked").val();

            console.log(length);

            $.ajax({
                type: "POST",
                url: "https://bgn.rainteam.xyz/api/op",
                timeout: 50000,      // Timeout 5000ms
                data: JSON.stringify({key: key, data1: data1, data2: data2, op: op}),
                dataType: "json",
                success: function(data) {
                    console.log(data);

                    if (data['status'] == 'success')
                    {
                        $("#op .panel-default .panel-footer div .data").val(data['data']);
                        $.notify("Operation finished in " + data['time'] + "s ", "success");
                    } else 
                    {
                        $.notify(data['msg'], "error");
                    }
                },
                error: function(x, t, m) {
                    $.notify(console.log(x.responseText), "error");
                }
            });
        }
    </script>
{/literal}
<div id="op" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="fa fa-calculator"></span> Operation
            </h1>
        </div>

        <div class="panel-body">
            <div class="form-group">
                <label for="">Working mode</label>
                <br/>
                <label class="radio-inline"><input type="radio" name="op" value="add">Addition</label>
                <label class="radio-inline"><input type="radio" name="op" value="sub">Substraction</label>
                <label class="radio-inline"><input type="radio" name="op" value="mul">Multiplication</label>
            </div>

            <div class="form-group">
                <label for="">Public key</label>
                <textarea class="form-control key" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the first number</label>
                <textarea class="form-control data1" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the second number</label>
                <textarea class="form-control data2" rows="5"></textarea>
            </div>

            <button class="btn btn-success" style="float: right;" onclick="operation()">Start !</button>
        </div>

        <div class="panel-footer">
            <div class="form-group">
                <label for="">Result</label>
                <textarea class="form-control data" rows="5"></textarea>
            </div>
        </div>
    </div>
</div>

<!--
<div id="div" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="glyphicon glyphicon-ban-circle"></span> Dividing two numbers
            </h1>
        </div>
        <div class="panel-body">
            Explain why we don't do it.
        </div>
    </div>
</div>
-->


{literal}
    <script type="text/javascript">
        function expression()
        {
            $.notify("Please wait ...", "warn");

            var key = $("#expr .panel-default .panel-body div .key").val();
            var expr = $("#expr .panel-default .panel-body div .expr").val();

            $.ajax({
                type: "POST",
                url: "https://bgn.rainteam.xyz/api/op",
                timeout: 120000,      // Timeout 5000ms
                data: JSON.stringify({key: key, op: "expr", expr: expr}),
                dataType: "json",
                success: function(data) {
                    console.log(data);

                    if (data['status'] == 'success')
                    {
                        $("#expr .panel-default .panel-footer div .data").val(data['data']);
                        $.notify("Operation finished in " + data['time'] + "s ", "success");
                    } else 
                    {
                        $.notify(data['msg'], "error");
                    }


                },
                error: function(x, t, m) {
                    $.notify(console.log(x.responseText), "error");
                }
            });
        }
    </script>
{/literal}
<div id="expr" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="fa fa-calculator"></span> Expression
            </h1>
        </div>

        <div class="panel-body">
            <div class="form-group">
                <label for="">Public key</label>
                <textarea class="form-control key" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Expression</label>
                <textarea class="form-control expr" rows="5" placeholder="( H4sIAC9NN... + oVXTsx5PAWT0rn5... ) * Xgui/DSQmnu... "></textarea>
            </div>

            <button class="btn btn-success" style="float: right;" onclick="expression()">Start !</button>
        </div>

        <div class="panel-footer">
            <div class="form-group">
                <label for="">Result</label>
                <textarea class="form-control data" rows="5"></textarea>
            </div>
        </div>
    </div>
</div>

<script>
function upload() {
    var fd = new FormData();
    fd.append('file', $('input[type=file]')[0].files[0]);


    $.notify("Please wait ...", "warn");

    $.ajax({
        url: 'https://bgn.rainteam.xyz/api/file',
        data: fd,
        processData: false,
        contentType: false,
        type: 'POST',
        success: function (data) {
            $("#file .panel-default .panel-footer div .data").val(data['download']);

            $.notify("Operation finished in " + data['time'] + "s ", "success");        }
    });

    return false;
}
</script>

<div id="file" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="fa fa-file"></span> Calculate salary
            </h1>
        </div>

        <div class="panel-body">

            <form action="#" enctype="multipart/form-data" method="post" onsubmit="event.preventDefault(); upload();">
                <div class="form-group">

                    <label for="file">Salary file</label><br/>
                    <label class="file-upload btn btn-primary">
                        Browse for file ... <input type="file" />
                    </label>
                </div>

                <div class="alert alert-info">
                    Example file: <a target="_blank" href="https://files.rainteam.xyz/pUOTz/test.csv">https://files.rainteam.xyz/pUOTz/test.csv</a>
                </div>

                <button type="submit" class="btn btn-success" style="float: right;">Submit</button>
            </form>
        </div>

        <div class="panel-footer">
            <div class="form-group">
                <label for="">Result</label>
                <textarea class="form-control data" rows="5"></textarea>
            </div>
        </div>
    </div>
</div>



<div id="userinfo" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="fa fa-info-circle"></span> User Infomation
            </h1>
        </div>
        <div class="panel-body">
            <ul>
                <li>Username: {$username}</li>
                <li>Email: {$email}</li>
            </ul>
        </div>
    </div>
</div>
</body>
</html>

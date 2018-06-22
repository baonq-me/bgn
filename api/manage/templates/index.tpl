<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

    <title>Homomorphic encryption over elliptic curve</title>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">

    <!-- JQuery -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <script type="text/javascript">
        function showTab(tabId)
        {
            var list = ['add', 'sub', 'mul', 'div', 'userinfo', 'home', 'genkey'];

            for (var i = 0; i < list.length; i++)
                {
                    $('#' + list[i]).addClass("hide");
                    $('#' + list[i] + '-nav').removeClass("active");
                }


            $('#' + tabId).removeClass("hide");
            $('#' + tabId + '-nav').addClass("active");
        }

        $(document).ready(function(){
            $('[data-toggle="tooltip"]').tooltip();

            var id = window.location.href.split('#/').pop();

            console.log(id);

            if (id != '')
                {
                    $('#' + id + '-nav').click();
                }
        });
    </script>

    <style type="text/css">
        .hide {
            display: none;
        }


        .things{
            opacity:0.3;
        }

        .panel:hover .things{
            display:block;
            opacity: 1;
            transition: width, border opacity .0s linear .2s;
            -webkit-transition: width, border opacity .0s linear .2s;
            -moz-transition: width, border opacity .0s linear .2s;
            -ms-transition: width, border opacity .0s linear .2s;

            transition: opacity .2s linear .2s;
            -webkit-transition: opacity .2s linear .2s;
            -moz-transition: opacity .2s linear .2s;
            -ms-transition: opacity .2s linear .2s;
        }

        .panel-footer{
            background-color:#ffffff !important;
            font-size:16px;
        }

        textarea
        {
            font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;
        }

        nav .container
        {
            margin-top: 0px !important;
        }

        .container
        {
            margin-top: 70px;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-default navbar-fixed-top">
    <div class="container">
        <div class="navbar-header">
            <a class="navbar-brand" href="/">Homomorphic encryption</a>
        </div>
        <ul class="nav navbar-nav" role="tablist">
            <li id="home-nav" class="active" onclick="showTab('home')"><a href="#home">Home</a></li>
            <li id="genkey-nav" data-toggle="tooltip" data-placement="bottom" title="Generate key pairs" onclick="showTab('genkey')"><a href="#genkey"><span class="glyphicon glyphicon-lock"></span> Make keys</a></li>
            <li id="add-nav" data-toggle="tooltip" data-placement="bottom" title="Addition" onclick="showTab('add')"><a href="#/add"><span class="glyphicon glyphicon-plus"></span> Addition</a></li>
            <li id="sub-nav" data-toggle="tooltip" data-placement="bottom" title="Substraction" onclick="showTab('sub')"><a href="#/sub"><span class="glyphicon glyphicon-minus"></span> Substraction</a></li>
            <li id="mul-nav" data-toggle="tooltip" data-placement="bottom" title="Multiplication" onclick="showTab('mul')"><a href="#/mul"><span class="glyphicon glyphicon-remove"></span> Multiplication</a></li>
            <li id="div-nav" data-toggle="tooltip" data-placement="bottom" title="Division" onclick="showTab('div')"><a href="#/div"><span class="glyphicon glyphicon-ban-circle"></span> Division</a></li>
        </ul>
        <ul class="nav navbar-nav navbar-right">
            <li class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="/"><span class="glyphicon glyphicon-user"></span> User
                    <span class="caret"></span></a>
                <ul class="dropdown-menu">
                    <li id="userinfo-nav" data-toggle="tooltip" data-placement="left" title="User Information" onclick="showTab('userinfo')"><a href="#/userinfo"><span class="glyphicon glyphicon-info-sign"></span> Infomation</a></li>
                    <li id="logout-nav" data-toggle="tooltip" data-placement="left" title="Logout" onclick="alert('Logging out')"><a href="#/logout"><span class="glyphicon glyphicon-log-out"></span> Logout</a></li>
                </ul>
            </li>
        </ul>
    </div>
</nav>

<div id="home" class="container">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="glyphicon glyphicon-info-sign"></span> Somewhat homomorphic encryption over elliptic curve using BGN algorithm
            </h1>
        </div>
        <div class="panel-body">
            <object data="https://code.rainteam.xyz/static/pdf/bgn.pdf" type="application/pdf" width="100%" height="500px">
                <p><b>Homomorphic Encryption and the BGN Cryptosystem</b>: This browser does not support PDFs. Please download the PDF to view it: <a href="https://code.rainteam.xyz/static/pdf/bgn.pdf">Download PDF</a>.</p>
            </object>
        </div>
    </div>
</div>

<div id="genkey" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="glyphicon glyphicon-lock"></span> Generate/Test key pairs
            </h1>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="">Public key</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Private key</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <button class="btn btn-success" style="float: right;">Start !</button>
        </div>
    </div>
</div>

<div id="add" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="glyphicon glyphicon-plus"></span> Adding two numbers
            </h1>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="">Public key</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the first number</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the second number</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="panel-footer">
                <div class="form-group">
                    <label for="">Result</label>
                    <textarea class="form-control" rows="5"></textarea>
                </div>

                <button class="btn btn-success" style="float: right;">Start !</button>
            </div>
        </div>
    </div>
</div>

<div id="sub" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="glyphicon glyphicon-minus"></span> Subtracting two numbers
            </h1>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="">Public key</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the first number</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the second number</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="panel-footer">
                <div class="form-group">
                    <label for="">Result</label>
                    <textarea class="form-control" rows="5"></textarea>
                </div>

                <button class="btn btn-success" style="float: right;">Start !</button>
            </div>
        </div>
    </div>
</div>

<div id="mul" class="container hide">
    <div class="panel panel-default">
        <div class="panel-heading">
            <h1 class="panel-title">
                <span class="glyphicon glyphicon-remove"></span> Multiplying two numbers
            </h1>
        </div>
        <div class="panel-body">
            <div class="form-group">
                <label for="">Public key</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the first number</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="form-group">
                <label for="">Ciphertext of the second number</label>
                <textarea class="form-control" rows="5"></textarea>
            </div>

            <div class="panel-footer">
                <div class="form-group">
                    <label for="">Result</label>
                    <textarea class="form-control" rows="5"></textarea>
                </div>

                <button class="btn btn-success" style="float: right;">Start !</button>
            </div>
        </div>
    </div>
</div>

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

<div id="userinfo" class="hide">
    userinfo
</div>



<!-- Bootstrap -->
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

<!-- Notification-->
<script src="https://rawgit.com/notifyjs/notifyjs/master/dist/notify.js" type="text/javascript"></script>

<!-- PDF Object -->
<script src="https://code.rainteam.xyz/static/js/pdfobject.min.js" type="text/javascript"></script>

</body>
</html>

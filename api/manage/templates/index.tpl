<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

    <title>Homomorphic encryption over elliptic curve</title>

    <link href="//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css" rel="stylesheet">

    <!-- JQuery -->
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>

    <!-- Bootstrap -->
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

    <script src="https://rawgit.com/notifyjs/notifyjs/master/dist/notify.js" type="text/javascript"></script>
    <script type="text/javascript">
        function showTab(tabId)
        {
            var list = ['add', 'sub', 'mul', 'div', 'userinfo', 'home'];

            for (var i = 0; i < list.length; i++)
                $('#' + list[i]).addClass("hide");

            $('#' + tabId).removeClass("hide");
        }

        $(document).ready(function(){
            $('[data-toggle="tooltip"]').tooltip();
        });
    </script>

    <style type="text/css">
        .hide {
            display: none;
        }

        .show {
            display: block;
        }
    </style>
</head>
<body>

<nav class="navbar navbar-default">
    <div class="container-fluid">
        <div class="navbar-header">
            <a class="navbar-brand" href="#">Homomorphic encryption</a>
        </div>
        <ul class="nav navbar-nav" role="tablist">
            <li class="active" onclick="showTab('home')"><a href="/">Home</a></li>
            <li data-toggle="tooltip" data-placement="bottom" title="Addition" onclick="showTab('add')"><a href="#"><span class="glyphicon glyphicon-plus"></span> Addition</a></li>
            <li data-toggle="tooltip" data-placement="bottom" title="Substraction" onclick="showTab('sub')"><a href="#"><span class="glyphicon glyphicon-minus"></span> Substraction</a></li>
            <li data-toggle="tooltip" data-placement="bottom" title="Multiplication" onclick="showTab('mul')"><a href="#"><span class="glyphicon glyphicon-remove"></span> Multiplication</a></li>
            <li data-toggle="tooltip" data-placement="bottom" title="Division" onclick="showTab('div')"><a href="#"><span class="glyphicon glyphicon-ban-circle"></span> Division</a></li>
        </ul>
        <ul class="nav navbar-nav navbar-right">
            <li class="dropdown">
                <a class="dropdown-toggle" data-toggle="dropdown" href="#"><span class="glyphicon glyphicon-user"></span> User
                    <span class="caret"></span></a>
                <ul class="dropdown-menu">
                    <li data-toggle="tooltip" data-placement="left" title="User Information" onclick="showTab('userinfo')"><a href="#"><span class="glyphicon glyphicon-info-sign"></span> Infomation</a></li>
                    <li data-toggle="tooltip" data-placement="left" title="Logout" onclick="alert('Logging out')"><a href="#"><span class="glyphicon glyphicon-log-out"></span> Logout</a></li>
                </ul>
            </li>
        </ul>
    </div>
</nav>

<div id="home">
    <p>Homomorphic encryption is a form of encryption that allows computation on ciphertexts, generating an encrypted result which, when decrypted, matches the result of the operations as if they had been performed on the plaintext. The purpose of homomorphic encryption is to allow computation on encrypted data.</p>
    <p>Cloud computing platforms can perform difficult computations on homomorphically encrypted data without ever having access to the unencrypted data. Homomorphic encryption can also be used to securely chain together different services without exposing sensitive data. For example, services from different companies can calculate 1) the tax, 2) the currency exchange rate, and 3) shipping on a transaction without exposing the unencrypted data to each of those services.[1] Homomorphic encryption can also be used to create other secure systems such as secure voting systems,[2] collision-resistant hash functions, and private information retrieval schemes.</p>
    <p>Homomorphic encryption schemes are inherently malleable. In terms of malleability, homomorphic encryption schemes have weaker security properties than non-homomorphic schemes.</p>
</div>

<div id="add" class="hide">
    Add
</div>

<div id="sub" class="hide">
    sub
</div>

<div id="mul" class="hide">
    mul
</div>

<div id="div" class="hide">
    div
</div>

<div id="userinfo" class="hide">
    userinfo
</div>

</body>
</html>

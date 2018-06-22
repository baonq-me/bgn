<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

    <title>Homomorphic encryption over elliptic curve</title>

    <link rel="stylesheet" href="static/css/login.css" media="all">
    <link href="//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-1.11.3.min.js" type="text/javascript"></script>
    <script src="https://rawgit.com/notifyjs/notifyjs/master/dist/notify.js" type="text/javascript"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            $("form").submit(function( event ) {

                var data = {};
                data.username = $("input[name=username]").val();
                data.email = $("input[name=email]").val();

                $.ajax({
                    type: "POST",
                    url: 'index.php',
                    timeout: 10000,      // Timeout 10s
                    data: data,
                    dataType: "json",
                    success: function(data) {
                        location.reload();
                    },
                    error: function(x, t, m) {
                        console.log(x);
                        console.log(t);
                        console.log(m);
                        $.notify("Error", "error");
                    }
                });



                event.preventDefault();
            });
        });
    </script>
</head>
<body>
<div id="logo" onclick="location.reload();">
    <img style="height: 120px" src="static/images/logo.png" alt="">
</div>

<div id="container">
    <div class="content-top-agile">
        <h2>Homomorphic encryption<br/>over elliptic curve</h2>
    </div>

    <div class="content-bottom">
        <form action="/index.php" method="post">
            <div class="field-group">
                <span class="fa fa-user"></span>
                <div class="wthree-field">
                    <input name="username" id="username" type="text" value="" placeholder="Username" required>
                </div>
            </div>
            <div class="field-group">
                <span class="fa fa-envelope"></span>
                <div class="wthree-field">
                    <input name="email" id="email" type="email" placeholder="Email" required>
                </div>
            </div>

            <div class="wthree-field">
                <input type="submit" value="Login" />
            </div>
        </form>
    </div>
    <div class="register">
        <p>1412661 - Nguyen Quoc Bao</p>
        <p>1412170 - Nguyen Thi Thu Hien</p>
    </div>
</div>
</body>
</html>

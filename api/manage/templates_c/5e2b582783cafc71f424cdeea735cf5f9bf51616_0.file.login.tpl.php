<?php
/* Smarty version 3.1.32, created on 2018-07-10 06:12:21
  from '/var/www/html/manage/templates/login.tpl' */

/* @var Smarty_Internal_Template $_smarty_tpl */
if ($_smarty_tpl->_decodeProperties($_smarty_tpl, array (
  'version' => '3.1.32',
  'unifunc' => 'content_5b444e452ec2c0_15357107',
  'has_nocache_code' => false,
  'file_dependency' => 
  array (
    '5e2b582783cafc71f424cdeea735cf5f9bf51616' => 
    array (
      0 => '/var/www/html/manage/templates/login.tpl',
      1 => 1531203064,
      2 => 'file',
    ),
  ),
  'includes' => 
  array (
  ),
),false)) {
function content_5b444e452ec2c0_15357107 (Smarty_Internal_Template $_smarty_tpl) {
?><!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />

    <title>Homomorphic encryption over elliptic curve</title>

    <link rel="stylesheet" href="static/css/login.css" media="all">
    <link href="//netdna.bootstrapcdn.com/font-awesome/4.0.3/css/font-awesome.css" rel="stylesheet">
    <?php echo '<script'; ?>
 src="https://code.jquery.com/jquery-1.11.3.min.js" type="text/javascript"><?php echo '</script'; ?>
>
    <?php echo '<script'; ?>
 src="https://rawgit.com/notifyjs/notifyjs/master/dist/notify.js" type="text/javascript"><?php echo '</script'; ?>
>
    <?php echo '<script'; ?>
 type="text/javascript">
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
    <?php echo '</script'; ?>
>
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
<?php }
}

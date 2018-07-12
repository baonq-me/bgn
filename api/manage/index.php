<?php

session_start();

require_once(__DIR__.'/vendor/autoload.php');
error_reporting(E_ERROR);



if ($_POST['username'] != '' and $_POST['email'] != '')
{
    $_SESSION['username'] = $_POST['username'];
    $_SESSION['email'] = $_POST['email'];
    http_response_code(200);

    echo json_encode(['msg' => 'success']);
    exit(0);
}

if ($_GET['logout'] == 'logout')
{
    unset($_SESSION['username']);
    unset($_SESSION['email']);

    exit(0);
}


$smarty = new SmartyBC();

if ($_SESSION['username'] == '')
{
    $smarty->display(__DIR__.'/templates/login.tpl');
} else
{
    $smarty->assign("username", $_SESSION['username']);
    $smarty->assign("email", $_SESSION['email']);
    $smarty->display(__DIR__.'/templates/index.tpl');
}
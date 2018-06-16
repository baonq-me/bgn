<?php

require_once(__DIR__.'/vendor/autoload.php');
error_reporting(E_ERROR);

$smarty = new SmartyBC();

if ($_SESSION['user'] == '')
{
    $smarty->display(__DIR__.'/templates/index.tpl');
}
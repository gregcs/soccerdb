<!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
<script src="./assets/jquery/jquery.js"></script>
<!-- Include all compiled plugins (below), or include individual files as needed -->
<script src="./assets/bootstrap/js/bootstrap.min.js"></script>

<script>
    $(document)
        .ajaxStart(function() {
            $('#loading').show();
        })
        .ajaxStop(function() {
            $('#loading').hide();

        });
</script> 
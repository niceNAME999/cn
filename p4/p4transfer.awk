BEGIN {
    sent=0;
    rec=0;
}
{
    if($1=="r" && $4=="1" && $5=="tcp"){
        rec+=$6
    }
    if($1=="+" && $3=="0" && $5=="tcp"){
        sent+=$6
    }
}
END{
    printf("sendt %f" , sent)
    printf("rec %f ",rec)
}

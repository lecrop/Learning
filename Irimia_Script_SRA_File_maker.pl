open (I, $ARGV[0]);

open (O, ">$ARGV[0].out");



system "mkdir SRA" unless (-e "SRA");



while (<I>){

    s/\r//g;

    s/\"//g;

    ($sra)=/(.+)/;

    

    sleep 2 unless (-e "$sra" || -e "SRA/$sra");

    system "wget https://www.ncbi.nlm.nih.gov/sra/$sra -O SRA/$sra" unless (-e "$sra" || -e "SRA/$sra");



    open (F, "SRA/$sra");

    $/="";

    $PE=$n_reads=$all_info="";

    while (<F>){

	if (/$sra\<\/a\>\<\/td\>\<td align\=\"right\"\>(.+?)\<\/td\>\<td align\=\"right\"\>(.+?)\<\/td\>\<td align/){$n_reads=$1;$bases=$2;}

	if (/(\>Sample\: .+?)\>Library\:/){$all_info1=$1;}

	if (/(\>Library\: .+?)\>Runs\:/){$all_info2=$1;}

	if (/Layout\: \<span\>PAIRED\<\/span\>/){$PE="PE";}

	elsif (/Layout\: \<span\>SINGLE\<\/span\>/){$PE="SE";}

    }

    close F;

    $/="\n";



    ($bp,$mult)=$bases=~/(.+)(\w)$/;

    $bases=$bp*1000 if $mult eq "K";

    $bases=$bp*1000000 if $mult eq "M";

    $bases=$bp*1000000000 if $mult eq "G";

    

    $n_readsT=$n_reads;

    $n_readsT=~s/\,//g;

    $le=sprintf("%.0f",$bases/$n_readsT) if $n_readsT>0;

    $le="NA" if $n_readsT==0;





    ($info1)=$all_info1=~/\>Sample\:.+?\>(.+?)\</;

    ($info2)=$all_info2=~/\>Name\:.+?\>(.+?)\</;



   

    print O "$sra\t$info1\t$info2\t$n_reads\t$le\t$PE\n";

}


exit;
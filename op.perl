#!/usr/bin/perl
	
	
	use strict;
	
	use Term::ReadKey;
	
	use Digest::MD5 qw( md5 md5_hex );
	
	
	sub sStringXor {
		
		my $sOutput = '';
		
		my ( $sBase , $sInput ) = ( @_ );
		
		my $iBaseL = length( $sBase );
		my $iInputL = length( $sInput );
		for ( my $iI = 0 ; $iI < $iInputL ; $iI ++ ) {
			my $iInChar = ord( substr( $sInput , $iI , 1 ) );
			my $iB = $iI % $iBaseL;
			my $iBaseChar = ord( substr( $sBase , $iB , 1 ) );
			my $iOutChar = $iBaseChar ^ $iInChar;
			my $sOutChar = chr( $iOutChar );
			$sOutput .= $sOutChar;
		}
		
		return $sOutput;
		
	}
	
	
	if ( ! ( $ARGV[1] && ( 'get' eq $ARGV[0] || 'set' eq $ARGV[0] && $ARGV[2] ) ) ) {
		print ':usage:'."\n".' o_pass get [key]'."\n".' pass set [key] [val]'."\n";
		exit;
	}
	
	
	my $sPass = '';
	print ' pass: ';
	ReadMode( 'noecho' );
	$sPass = <STDIN>;
	ReadMode( 1 );
	print "\r";
	chomp $sPass;
	#print 'pass: "' . $sPass . '"' . "\n";
	if ( !$sPass ) {
		print ' pass read failed ' . "\n";
		exit;
	}
	
	
	my $sPassHash = '';
	$sPassHash .= md5( 'a' . $sPass . 'a' );
	$sPassHash .= md5( 'b' . $sPass . 'b' );
	$sPassHash .= md5( 'c' . $sPass . 'c' );
	
	my $sFile = '/c/aaa/msc/store/hexadecimal.txt';
	
	my $sKeyWord = $ARGV[0];
	
	my $sKey = $ARGV[1];
	
	my $sKeyHash = uc md5_hex( 'salt' . $sKey . 'tlas' );
	
	open( my $oRead , '<' , $sFile );
	chomp( my @aLines = <$oRead> );
	close( $oRead );
	
	if ( 'set' eq $sKeyWord && $ARGV[2] ) {
		
		my $sVal = $ARGV[2];
		
		my $sValXor = sStringXor( $sPassHash , $sVal );
		my $sValXorHex = '';
		my $iValXorL = length( $sValXor );
		for ( my $iI = 0 ; $iI < $iValXorL ; $iI ++ ) {
			my $iValChar = ord( substr( $sValXor , $iI , 1 ) );
			$sValXorHex .= sprintf( "%02X" , $iValChar );
		}
		
		print ' set "' . $sKey . '" to "' . $sVal . '"' . "\n";
		
		my $sOutput = '';
		
		my $bFound = 0;
		
		foreach my $sLine ( @aLines ) {
			if ( $sLine =~ m/^$sKeyHash/ ) {
				$sLine = $sKeyHash . $sValXorHex;
				$bFound = 1;
			}
			$sOutput .= $sLine . "\n";
		}
		
		if ( ! $bFound ) {
			my $sNewLine = $sKeyHash . $sValXorHex;
			$sOutput .= $sNewLine . "\n";
		}
		
		open( my $oWrite , '>' , $sFile );
		print $oWrite $sOutput;
		close( $oWrite );
		
	}
	
	if ( 'get' eq $sKeyWord ) {
		
		print ' get "' . $sKey . '"' . "\n";
		
		my $sValXor = '';
		
		my $bFound = 0;
		
		foreach my $sLine ( @aLines ) {
			if ( $sLine =~ m/^$sKeyHash/ ) {
				my $sInVal = substr( $sLine , length( $sKeyHash ) );
				my $iInValL = length( $sInVal );
				for ( my $iI = 0 ; $iI < $iInValL ; $iI += 2 ) {
					my $sInTwo = substr( $sInVal , $iI , 2 );
					$sValXor .= chr( hex( $sInTwo ) );
				}
				$bFound = 1;
			}
		}
		
		if ( $bFound ) {
			my $sVal = sStringXor( $sPassHash , $sValXor );
			print ' ' . $sVal . "\n";
		} else {
			print ' ! NOT FOUND !' . "\n";
		}
		
	}
	
	
#

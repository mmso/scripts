#!/usr/bin/perl

use strict;
use warnings;
use open qw/:std :utf8/;
use utf8;

# 256-color terminal
my $color256 = 1; # extended colors disabled, 1 to enable
# colorschemes
#my $colorscheme = ''; #
#my $colorscheme = 'greyscale'; #
my $colorscheme = 'early'; #

# special padding if 256-colors or normal
my $paddingsz = 15;

## default colors
my @c;
$c[0]  = "\e[30  m";	# black
$c[1]  = "\e[30;1m";	# bright black
## size: K
$c[2]  = "\e[31  m";	# red
## size: G, rel: sek
$c[3]  = "\e[31;1m";	# bright red
## rel: day
$c[4]  = "\e[32  m";	# green
## perm: x
$c[5]  = "\e[32;1m";	# bright green
## perm: r
$c[6]  = "\e[33  m";    # yellow 
## size: M, perm: w
$c[7]  = "\e[33;1m";	# bright yellow
## perm: other
$c[8]  = "\e[34  m";    # blue
## rel: hour
$c[9]  = "\e[34;1m";	# bright blue
$c[10] = "\e[35  m";	# magenta
## perm: s
$c[11] = "\e[35;1m";	# bright magenta
$c[12] = "\e[36  m";	# cyan
## perm: l
$c[13] = "\e[36;1m";	# bright cyan
## size: B, delim: a, rel: month
$c[14] = "\e[37  m";	# white
## rel: min
$c[15] = "\e[33;1m";	# 
$c[16] = "\e[0m";		# default
$c[17] = "\e[1m";		# bold

# extended colors
if($color256 == 1) {
	$paddingsz = 21;

	if($colorscheme eq '') {
		$c[0]  = "\e[38;5;208  m";
		$c[1]  = "\e[38;5;197  m";
		$c[2]  = "\e[38;5;190  m";
		$c[3]  = "\e[38;5;196;1m";
		$c[4]  = "\e[38;5;242  m";
		$c[5]  = "\e[38;5;209  m";
		$c[6]  = "\e[38;5;185  m";
		$c[7]  = "\e[38;5;215  m";
		$c[8]  = "\e[38;5;032  m";
		$c[9]  = "\e[38;5;061  m";
		$c[10] = "\e[38;5;142  m";
		$c[11] = "\e[38;5;197;1m";
		$c[12] = "\e[38;5;106  m";
		$c[13] = "\e[38;5;060;1m";
		$c[14] = "\e[38;5;236  m";
		$c[15] = "\e[38;5;215  m";
	}

	if($colorscheme eq 'greyscale') {
		$c[0]  = "\e[38;5;252  m";
		$c[1]  = "\e[38;5;251  m";
		$c[2]  = "\e[38;5;250  m";
		$c[3]  = "\e[38;5;249;1m";
		$c[4]  = "\e[38;5;239  m";
		$c[5]  = "\e[38;5;244;1m";
		$c[6]  = "\e[38;5;240  m";
		$c[7]  = "\e[38;5;242  m";
		$c[8]  = "\e[38;5;244  m";
		$c[9]  = "\e[38;5;244  m";
		$c[10] = "\e[38;5;243  m";
		$c[11] = "\e[38;5;241  m";
		$c[12] = "\e[38;5;240  m";
		$c[13] = "\e[38;5;239  m";
		$c[14] = "\e[38;5;236  m";
		$c[15] = "\e[38;5;242  m";
	}

	if($colorscheme eq 'early') {
		$c[0]  = "\e[38;5;233  m";
		$c[1]  = "\e[38;5;245  m";
		$c[2]  = "\e[38;5;250  m";
		$c[3]  = "\e[38;5;201  m";
		$c[4]  = "\e[38;5;239  m";
		$c[5]  = "\e[38;5;214  m";
		$c[6]  = "\e[38;5;220  m";
		$c[7]  = "\e[38;5;166  m";
		$c[8]  = "\e[38;5;244  m";
		$c[9]  = "\e[38;5;254  m";
		$c[10] = "\e[38;5;243  m";
		$c[11] = "\e[38;5;241  m";
		$c[12] = "\e[38;5;240  m";
		$c[13] = "\e[38;5;239  m";
		$c[14] = "\e[38;5;237  m";
		$c[15] = "\e[38;5;220  m";
	}
}


## default delimiters
my @d;
#$d[0] = "├";
$d[0] = "▕";
$d[1] = "-";
#$d[2] = "▕▏";
$d[2] = "│";
#$d[3] = "┤";
$d[3] = "▏";

## set same color on all delims
for(@d) {
	$_ = "$c[14]$_$c[16]";
}

# gets current time for relative time calculation
my $curtime = time();

## expects following:
##	-rw-r--r-- 1 user group 32K 1280000000 name
open(LS, "ls -hvAl --group-directories-first --color=always --time=ctime --time-style=+%s @ARGV|") or die "fst";

## strip first row 
##	total 32K
$_ = <LS>;

while(<LS>) {
	## split some strings
	my ($perm, $hlink, $user, $group, $size, $seconds) = split(/\s+/);

	## parse filename separetly to allow for whitespace etc.
	my ($file) = m/.* \d{6,}? (.*)/;

	## calculate relative time
	my ($rel) = relative($curtime, $seconds);

	## color size
	$size = size($size);

	## color permissions
	$perm = perm($perm);

	## views
	#perm_file($perm, $file);
	#perm_size_file($perm, $size, $file);
	#time_perm_file($perm, $rel, $file);
	#time_perm_size_file($perm, $rel, $size, $file);
	perm_time_size_file($perm, $rel, $size, $file);
	#left_file($file, $size, 50);
	#right_file($size, $file, 50);
}

close LS;

## view: permissions and filename
## | <perm> | <filename>
sub perm_file{
	my ($perm, $file) = @_;
	printf("%s%s%s%s\n", $d[0], $perm, $d[3], $file);
}

## view: permissions, size and filename
## | <perm> | <size> | <filename>
sub perm_size_file{
	my ($perm, $size, $file) = @_;
	printf("%s%s%s%-19s%s%s\n", $d[0], $perm, $d[3], $size, $d[2], $file);
}

## view: permissions, time, size and filename
## <time> | <perm> | <filename>
sub time_perm_file{
	my ($perm, $rel, $file) = @_;
	printf("%s%s%s%s%s\n", $rel, $d[0], $perm, $d[3], $file);
}

## view: time, permissions, size and filename
## <time> | <perm> | <size> | <filename>
sub time_perm_size_file{
	my ($perm, $rel, $size, $file) = @_;
	printf("%s%s%s%s%-${paddingsz}s%s%s\n", $rel, $d[0], $perm, $d[3], $size, $d[2], $file);
}

## view: permissions, time, size and filename
## | <perm> | <size> | <filename>
sub perm_time_size_file{
	my ($perm, $rel, $size, $file) = @_;
	printf("%s%s%s%s%s%-${paddingsz}s%s%s\n", $d[0], $perm, $d[3], $rel, $d[2], $size, $d[2], $file);
}

## view: file to the right
## <var> | <filename>
sub right_file{
	my ($var, $file, $paddingright) = @_;
	printf("%${paddingright}s%s%s\n", $var, $d[2], $file);
}

## view: file to the left
## <...filename> | <var>
sub left_file{
	my ($file, $size, $paddingleft) = @_;

	## first row has a \e[0m
	$file =~ s/^\e\[0m//g;

	my ($esclen, $strlen) = (0, length($file));

	## for each escape sequence, pad the length of it
	while($file =~ m/\e\[(.*?m)/g) {
		$esclen += length($1);
	}

	## special symlink
	if($file =~ s/->/▻/) {
		$esclen += 5;
	}

	my $padlen = $paddingleft - $strlen + $esclen;

	## cut too long filenames
	if($padlen < 0) {
		$file = substr($file, 0, $padlen-7);
		$padlen = 0;
		$file = $file . "...\e[0m";
	}

	# pad with spaces
	#$file = $file . ( ' ' x $padlen);
	$file = ( ' ' x $padlen) . $file;

	printf("%s%s%s\n", $file, $d[2], $size);
}

## colorizes permissions
sub perm {
	my ($perm) = @_;

	$perm =~ s/-/$d[1]/g;
	$perm =~ s/(r)/$c[6]$1$c[16]/g;
	$perm =~ s/(w)/$c[7]$1$c[16]/g;
	$perm =~ s/(x)/$c[5]$1$c[16]/g;
	$perm =~ s/(d)/$c[8]$1$c[16]/g;
	$perm =~ s/(l)/$c[13]$1$c[16]/g;
	$perm =~ s/(s)/$c[11]$1$c[16]/g;
	$perm =~ s/(S)/$c[8]$1$c[16]/g;
	$perm =~ s/(t)/$c[8]$1$c[16]/g;
	$perm =~ s/(T)/$c[8]$1$c[16]/g;

	return $perm;
}

## colors the size string depending on whether its K, M, G or prefixless
sub size {
	my ($size) = @_;

	return $size if ($size =~ s/(.*)(K)/$c[2]$1$2$c[16]/);
	return $size if ($size =~ s/(.*)(M)/$c[7]$1$2$c[16]/);
	return $size if ($size =~ s/(.*)(G)/$c[3]$1$2$c[16]/);
	return $size if ($size =~ s/(\d+)/$c[14]$1$c[16]/);
}

## calculates relative time from the current time in seconds
sub relative {
	my ($cur, $sec) = @_;
	my $delta = $cur - $sec;
	my ($unit, $ret);

	## 0 < sec < 60
	$unit = "sek";
	$ret = $delta;

	return relativef($c[3], "<", $unit)		if $delta < 10;
	return relativef($c[3], $ret, $unit)	if $delta < 60;

	## 1 < min < 45
	$unit = "min";
	$ret = int($ret/60);

	return relativef($c[15], "<", $unit)		if $delta < 2 * 60;
	return relativef($c[15], $ret, $unit)	if $delta < 45 * 60;

	## 0.75 < hour < 42
	$unit = "tim";
	$ret = int($ret/60);

	return relativef($c[9], "<", $unit)		if $delta < 90 * 60;
	return relativef($c[9], $ret, $unit)	if $delta < 24 * 60 * 60;
	return relativef($c[9], $ret, $unit)	if $delta < 30 * 60 * 60;
	return relativef($c[9], $ret, $unit)	if $delta < 36 * 60 * 60;

	## 0.75 < day < 30
	$unit = "dag";
	$ret = int($ret/24);

	return relativef($c[4], "<", $unit)		if $delta < 48 * 60 * 60;
	return relativef($c[4], $ret, $unit)	if $delta < 7 * 24 * 60 * 60;
	return relativef($c[4], $ret, $unit)	if $delta < 14 * 24 * 60 * 60;
	return relativef($c[4], $ret, $unit)	if $delta < 28 * 24 * 60 * 60;
	return relativef($c[4], $ret, $unit)	if $delta < 30 * 24 * 60 * 60;

	## 1 < month < 12
	$unit = "mån";
	$ret = int($ret/30);

	return relativef($c[14], "<", $unit)		if $delta < 2 * 30 * 24 * 60 * 60;
	return relativef($c[14], $ret, $unit)	if $delta < 12 * 30 * 24 * 60 * 60;

	## 1 < years < inf
	$unit = "år ";
	$ret = int($ret/12);

	return relativef($c[0], $ret, $unit);
}

## format for relative time
sub relativef {
	my ($color, $string, $unit) = @_;
	return sprintf("%s%-2s%s%-3s%s", $color, $string, $c[17], $unit, $c[16]);
}

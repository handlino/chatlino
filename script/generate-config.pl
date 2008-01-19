#!/usr/bin/perl -l
use strict;

use YAML::Syck;
use Cwd;
use FindBin qw($Bin);

my %vars = (
        developer => $ENV{USER},
        uid       => $<,
        port      => 20000 + $<,
        pushport  => 21000 + $<,
        host      => $ENV{RAILS_HOST},
        socket    => '/tmp/mysql.sock'
        );

if ( -f "config/locomotive.yml" ) {
    my $c = LoadFile("config/locomotive.yml");
    $vars{port} = $c->{port};
}

process_template(
        "$Bin/../config/juggernaut_config.yml.template",
        "$Bin/../config/juggernaut_config.yml");

sub process_template {
    my ($in, $out) = @_;
    my $t = slurp($in);
    for (keys %vars) {
        $t =~ s/\$$_/$vars{$_}/g;
    }
    puke($out, $t);
    print "$out is generated.";
}

sub slurp {
    local $/ = undef;
    my $f = shift;
    open N, "<", $f or die $!;
    return <N>;
}

sub puke {
    my ($f,$o) = @_;
    open N, ">", $f or die $!;
    print N $o;
}


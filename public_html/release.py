#!/usr/bin/env python
import os, re, logging, sys

logging.basicConfig(level=logging.DEBUG)

def do_gitarchive(software, release, commitnum):
    # chdir
    os.chdir("..")
    try:
        assert "syncdb" in os.listdir(".")
        assert "dblink_plus" in os.listdir(".")
        assert "oracle_fdw" in os.listdir(".")
    except:
        print "ERROR: You are probably wrong dir"
    os.chdir(software)
    logging.debug("cwd: %s" % os.getcwd())
    # issue git archive
    cmd =  "git archive --format=tar --prefix=%s-%s/ %s | gzip > /tmp/%s-%s.tar.gz"  % (software,release,commitnum,software,release)
    print "%s [Y/n]" %cmd ,
    yesno = raw_input()
    if yesno.lower() == 'y' or yesno == '':
        import subprocess
        subprocess.call(cmd, shell=True)
        print "Done"
    else:
        sys.exit(1)

def report_error(msg):
    print "ERROR: %s. For more details, type %s --help" % (msg, __file__)
    sys.exit(1)

def parse_args():
    import optparse
    parser = optparse.OptionParser()
    parser.add_option('-s','--software',dest='software',help='choose either "dblink_plus", "syncdb" or "oracle_fdw"')
    parser.add_option('-r','--release',dest='release',help='input release number')
    parser.add_option('-n','--commitnum',dest='commitnum',help='input comminum')
    opts, args = parser.parse_args()
    # check for -s 
    try:
        assert opts.software in ["dblink_plus", "syncdb", "oracle_fdw"]
    except:
        report_error("invalid value for -s")
    # check for -r
    try:
        assert re.match(r"\d+\.\d+.\d+", opts.release)
    except:
        report_error("invalid value for -r")
    # check for -n
    try:
        assert opts.commitnum
    except:
        report_error("invalid value for -n")
    return opts.software, opts.release, opts.commitnum

def main():
    software, release, commitnum = parse_args()
    do_gitarchive(software, release, commitnum)

if __name__ == '__main__':
    main()

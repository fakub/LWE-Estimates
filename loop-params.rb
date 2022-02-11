#!/usr/bin/env ruby

require "yaml"

# threshold under which lambda is not calculated
LAMBDA_THR = 50.0
LAMBDA_DEF = 0.42

#N_RANGE_L = 128
#N_RANGE_U = 1152
#N_STEP    = 64

#MLA_RANGE_L = 5
#MLA_RANGE_U = 40
#MLA_STEP    = 5

N_RANGE_L = 128
N_RANGE_U = 2048
N_STEP    = 32

MLA_RANGE_L = 8
MLA_RANGE_U = 40
MLA_STEP    = 2

# hard paths
#~ SAGE_PATH = "/home/klemsa/sources/sage-9.4-Ubuntu_20.04-x86_64/SageMath/sage"
SAGE_PATH = "/home/fakub/sources/SageMath/sage"
LWE_EST_SAGE = "LWE-estimator.sage"
RES_FILE_BASE = "lwe-security"
LAMBDA_DB_YAML = RES_FILE_BASE + "-db.yaml"

# tmp paths
LWE_EST_TMP_PARAMS_SAGE = "LWE-estimator_tmp-with-params.sage"
LWE_EST_TMP_PARAMS_SAGE_PY = LWE_EST_TMP_PARAMS_SAGE + ".py"

# output paths
STR_RANGES = "n=#{N_RANGE_L}-#{N_STEP}-#{N_RANGE_U}_mla=#{MLA_RANGE_L}-#{MLA_STEP}-#{MLA_RANGE_U}"
RES_FILE = "#{RES_FILE_BASE}__#{STR_RANGES}.dat"
PNG_FILE = "#{RES_FILE_BASE}__#{STR_RANGES}.png"

def lwe_est(n, mla)
    est_code = File.read LWE_EST_SAGE

    est_code += "\n"
    est_code += "n, stdv = #{n}, 2^-#{mla}"
    est_code += '
set_verbose(1)
_ = estimate_lwe(n, sqrt(2*pi)*stdv, 2^32,  reduction_cost_model=BKZ.sieve, secret_distribution=(0,1))
'
    File.write LWE_EST_TMP_PARAMS_SAGE, est_code
    res = `#{SAGE_PATH} #{LWE_EST_TMP_PARAMS_SAGE} 2>&1`
    File.delete LWE_EST_TMP_PARAMS_SAGE    if File.exists? LWE_EST_TMP_PARAMS_SAGE
    File.delete LWE_EST_TMP_PARAMS_SAGE_PY if File.exists? LWE_EST_TMP_PARAMS_SAGE_PY

    pow = res[/2\^[0-9]+\.[0-9]+/]

    return pow.nil? ? -Float::INFINITY : pow.gsub("2^", "").to_f
end

File.write LAMBDA_DB_YAML, {}.to_yaml unless File.file? LAMBDA_DB_YAML

h = YAML.load(File.read LAMBDA_DB_YAML)

puts "(i) Running LWE Estimator"
File.open(RES_FILE, 'w') do |file|
    # header: n's
    file.write "   0"
    (N_RANGE_L..N_RANGE_U).step(N_STEP) do |n|
        file.write("  %6d" % n)
    end
    file.write "\n"
    file.flush
    # contents
    (MLA_RANGE_L..MLA_RANGE_U).step(MLA_STEP) do |mla|
        # first column: -log(alpha)
        file.write("%4d" % mla)
        # other columns: LWE estimates
        line = []
        last_l = Float::INFINITY
        N_RANGE_U.step(N_RANGE_L, -N_STEP) do |n|
            if h[[n,mla]].nil? and last_l >= LAMBDA_THR
                print "    Estimating n = #{n}, -log(alpha) = #{mla} ... " ; $stdout.flush
                sec = lwe_est(n, mla)
                puts "%.2f bits" % sec
                h[[n,mla]] = sec
                File.write LAMBDA_DB_YAML, h.to_yaml
            elsif last_l < LAMBDA_THR
                h[[n,mla]] = LAMBDA_DEF
                puts "    Skipping n = #{n}, -log(alpha) = #{mla} (lambda < #{LAMBDA_THR})."
            else
                puts "    Reading n = #{n}, -log(alpha) = #{mla} from YAML db."
            end
            last_l = h[[n,mla]]
            line << h[[n,mla]]
        end
        line.reverse.each{|l| file.write(" %7.2f" % l) }
        file.write "\n"
        file.flush
    end
end
puts "(i) Results written to '#{RES_FILE}'."

# run gnuplot script
system "gnuplot -c plot.sh #{RES_FILE} #{PNG_FILE} #{N_RANGE_U} #{N_STEP} #{MLA_RANGE_U} #{MLA_STEP}"
puts "(i) Find plot in '#{PNG_FILE}'."


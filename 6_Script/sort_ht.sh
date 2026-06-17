# 使用海涛师兄算法进行排序
input=$1
output=$2

head -n 9 $input > head.vcf

tail -n +10 $input | awk '{ rest = substr($0, index($0,$2)); print rest "\t" $1 }' | sort | awk '{ print $NF "\t" $0 }' | sed 's/[ \t]*[^\t]*$//' > Hap.vcf

cat head.vcf Hap.vcf > $output

rm -rf Hap.vcf head.vcf

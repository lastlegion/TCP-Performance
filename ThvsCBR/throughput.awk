BEGIN {packet_size= 1500
total_throughput = 0
final = 0
time_ini = 1.0
count = 0
}
{
ackn = $5
event = $1
time = $2
node = 0
flowid= $8
from_node = $3
to_node= $4 #from node should be 2
#print(event)
#print(time)
#print(flowid)
#print(from_node)
if(event == "r" && flowid == "1" && from_node == "0" && time_ini >= time && ackn == "tcp" ) {
#remember always immediately after if there will be start of the “{“ .not in next line
total_throughput = total_throughput + packet_size 
++count
}
if(event == "r" && flowid == "1" && from_node == "0" && time_ini <= time && 
ackn == "tcp") {
#print(count)
count = 0 
final = total_throughput + final
#print(total_throughput)
total_throughput = (total_throughput *8)/1000 
printf("%f\t%f\n" , time_ini , total_throughput ) > "Throughput"
total_throughput = 0
time_ini = time_ini + 1
}
}
END {
#print("*******************")
final = (((final *8)/1000 ) / time)
printf("%f ", final)
for (i = 1.00 ; i <= time_ini ; i++) printf("%f\t%f\n" , i , final ) > "Throughput_AVG"
}

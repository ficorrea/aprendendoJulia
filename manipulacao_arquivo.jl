arq = "teste.csv"

# Lendo manualmente - o open cria um IOStream
fl = open(arq, "r")
lines = [line for line in readlines(fl)]
close(fl)
println(lines)

fl = open(arq, "r") do io
    println("Read IO: ", read(io, String))
end

# Lendo com read - lê tudo de uma vez
rd = read(arq, String)
println("Read: ", rd)

# Lendo linha por linha
fl = open(arq, "r") do io
    for l in eachline(io)
        println("Read linha por linha: ", l)
    end
end

# Sobrescrevendo
fl = open(arq, "w")
new_col = ("4,40,400,D")
write(fl, new_col)
close(fl)

# Append num arquivo
fl = open(arq, "a")
new_col = ("\n5,50,500,E")
write(fl, new_col)
close(fl)
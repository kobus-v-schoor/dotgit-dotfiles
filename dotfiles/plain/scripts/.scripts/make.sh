#! /bin/bash

[[ -f .config ]] && source .config
[[ -z $FLAGS ]] && FLAGS="-std=c++11 -g -Wall -fdiagnostics-color=always"
[[ -z $RFLAGS ]] && RFLAGS="-std=c++11 -O3"
[[ -z $EXEC ]] && EXEC="main"
[[ -z $MAIN ]] && MAIN="main.cpp"
[[ $SUB ]] && SUB="$SUB/"

IFS=$'\n'

[[ $PWD =~ /home/cube/repos/cos* ]] && FLAGS="$FLAGS -static" && \
	RFLAGS="$RFLAGS -static"
FLAGS=${FLAGS#\ *}

echo -n > makefile

function deps
{
	arr=("$1")
	new=("$1")

	while [[ ${new[*]} ]]; do
		fns=(${new[@]})
		new=()

		for i in ${fns[@]}; do
			PRE=
			[[ $i =~ \/ ]] && PRE=${i%\/*}
			[[ -d $i ]] && continue

			while read -r inc; do
				inc=${inc#*\"}
				inc=${inc%\"*}
				[[ $PRE ]] && inc=$(realpath --relative-to="$PWD" "$PRE/$inc")

				if [[ "$inc" == $1 ]]; then
					echo "Circular dependency detected, skipping..." 1>&2
					return
				fi

				echo -e "${arr[*]}\n${new[*]}" | grep -Fxq "$inc" || new+=("$inc")
			done <<< $(grep -h '^#include\s*".*"' $i)
		done
		arr+=(${new[@]})
	done

	for i in ${arr[@]}; do
		echo "$i"
	done
}

function ctrg
{
	d=()
	d=$(deps "$1")
	o="$SUB${1%\.cpp}.o"
	[[ $SUB ]] && d+=("| ${o%\/*}") && bf+=("| ${o%\/*}")
	of+=("$o")
	echo -n "$o:" >> makefile
	for i in ${d[@]}; do
		[[ -d $i ]] && continue
		echo -e "${pd[*]}\n${bf[*]}"| grep -q "^$i$" || pd+=("$i")
		echo " \\" >> makefile
		echo -n " $i" >> makefile
	done
	echo -e "\n\t\$(go) $1 -o $o\n" >> makefile
}

function exc
{
	echo -n "$SUB$EXEC:"
	for i in ${of[@]}; do
		echo " \\"
		echo -n " $i"
	done
	echo -e "\n\tg++ \$(gf) ${of[@]} -o $SUB$EXEC\n"
}

pd=()
of=()
bf=()
ctrg "$MAIN"

while read -r fl; do
	fl=${fl#\.\/}
	echo "${pd[*]}" | grep -q "^$fl$" || ctrg "$fl"
done <<< $(find -name '*.cpp')

bf=($(echo "${bf[*]}" | sort -u))
for i in ${bf[@]}; do
	i=${i#|\ }
	echo -e "$i:\n\tmkdir -p $i\n" >> makefile
done

mv makefile tmp

echo -e "ifeq (\$(wildcard ${SUB}last_build),)" >> makefile
echo -e " ifndef gf\n  gf = $FLAGS\n endif" >> makefile
echo -e " ifndef go\n  go = g++ -c \$(gf)\n endif" >> makefile
echo -e "else" >> makefile
echo -e " ifeq (\$(shell cat ${SUB}last_build),debug)" >> makefile
echo -e "  ifndef gf\n   gf = $FLAGS\n  endif" >> makefile
echo -e "  ifndef go\n   go = g++ -c \$(gf)\n  endif" >> makefile
echo -e " else" >> makefile
echo -e "  ifndef gf\n   gf = $RFLAGS\n  endif" >> makefile
echo -e "  ifndef go\n   go = g++ -c \$(gf)\n  endif" >> makefile
echo -e " endif" >> makefile
echo -e "endif\n" >> makefile


echo -e "SHELL = /bin/bash" >> makefile
echo -e ".PHONY: auto debug release run gdb clean tar\n" >> makefile

echo -e "auto: | ${SUB}last_build" >> makefile
echo -e "\tif [[ \$\$(cat ${SUB}last_build) == debug ]]; then \\" >> makefile
echo -e "\t\t\$(MAKE) debug; \\" >> makefile
echo -e "\telse \\" >> makefile
echo -e "\t\t\$(MAKE) release; \\" >> makefile
echo -e "\tfi\n" >> makefile

echo -e "debug: | ${SUB}last_build" >> makefile
echo -e "\texport gf=\"$FLAGS\"; \\" >> makefile
echo -e "\texport go=\"g++ -c \$\$gf\"; \\" >> makefile
echo -e "\t[[ \$\$(cat ${SUB}last_build) != debug ]] && \$(MAKE) clean; \\" >> \
	makefile
echo -e "\techo debug > ${SUB}last_build; \\" >> makefile
echo -e "\t\$(MAKE) $SUB$EXEC\n" >> makefile

echo -e "release: | ${SUB}last_build" >> makefile
echo -e "\texport gf=\"$RFLAGS\"; \\" >> makefile
echo -e "\texport go=\"g++ -c \$\$gf\"; \\" >> makefile
echo -e "\t[[ \$\$(cat ${SUB}last_build) != release ]] && \$(MAKE) clean; \\" >> \
	makefile
echo -e "\techo release > ${SUB}last_build; \\" >> makefile
echo -e "\t\$(MAKE) $SUB$EXEC\n" >> makefile

echo -e "${SUB}last_build:" >> makefile
[[ $SUB ]] && echo -e "\tmkdir -p \"$SUB\"" >> makefile
echo -e "\techo debug > ${SUB}last_build\n" >> makefile

exc >> makefile
cat tmp >> makefile
rm tmp

PRE=
[[ $SUB ]] && PRE="cd $SUB;"

echo -e "run: \$(shell [[ -f ${SUB}last_build ]] && cat ${SUB}last_build ||" \
	"echo debug) | ${SUB}last_build" >> makefile
echo -e "\t${PRE}./$EXEC\n" >> makefile
echo -e "gdb: debug\n\t${PRE}gdb $EXEC\n" >> makefile
echo -e "clean:\n\trm -f ${of[@]} $(basename "$PWD").tar.gz $SUB$EXEC\n" \
	>> makefile
echo -e "tar:\n\ttar -chvz ${pd[@]} makefile -f $(basename "$PWD").tar.gz\n" \
	>> makefile

[[ -f ".cust_targets" ]] && cat .cust_targets >> makefile

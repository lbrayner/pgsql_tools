#!/bin/sh

# set -x

print_usage() {
	printf "\n$(basename "${0}") [-h] [-d FOLDER] [-p TEMPDIR] -c CLASSIFIER\
 [-- ARGS...]\n"
}

generate_timestamp(){
    date +'%Y%m%d_%H%M_%N'
}

destination="."
tmp="/tmp"

while getopts ":hc:d:p:" opt
do
    case ${opt} in
        c)
            classifier="${OPTARG}"
            ;;
        d)
            destination="${OPTARG}"
            ;;
        p)
            tmp="${OPTARG}"
            ;;
        h)
            print_usage
            exit 0
            ;;
        \?)
            ;;
    esac
done
shift $((OPTIND - 1))

if [ -z "${classifier}" ]
then
    print_usage 1>&2
    exit 1
fi

destination="$(readlink -f "${destination}")"

if [ ! -d "${destination}" ]
then
    echo "'${destination}' not a folder." 1>&2
    exit 1
fi

dump_name="pgsql_dump${classifier}$(generate_timestamp).sql"

dump_tmpdir="$(mktemp -d -p "${tmp}")"
dump="${dump_tmpdir}/${dump_name}"
pg_dump "${@}" -f "${dump}"
previous_dir="${PWD}"
cd "${dump_tmpdir}"
zip="${destination}/${dump_name}.zip"
zip "${zip}" "${dump_name}"
cd "${previous_dir}"
rm -rf "${dump_tmpdir}"

printf "\n${zip}\n"

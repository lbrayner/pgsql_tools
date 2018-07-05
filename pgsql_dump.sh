#!/bin/sh

# set -x

script_name="$(basename "${0}")"

print_usage() {
	printf '\n%s\n' "${script_name} [-h] [-d FOLDER] [-c CLASSIFIER] [-p TEMPDIR]\
 [-- ARGS...]"
}


generate_timestamp(){
    date +'%Y%m%d_%H%M_%N'
}

dump_pack(){

    name="${1}"
    shift 1

    dirname_dump_file="$(mktemp -d -p "${tmpdir}")"
    dump_file="${dirname_dump_file}/${name}"
    basename_dump_file="${name}"
    target_zip_file="${destination}/${name}.zip"
    pg_dump "${@}" -f "${dump_file}"
    cd "${dirname_dump_file}"
    zip "${target_zip_file}" "${basename_dump_file}"
    cd -
    rm -rf "${dirname_dump_file}"
}

if [ ! ${#} -gt 0 ]
then
	print_usage
	exit 1
fi

classifier=""
destination="."
tmpdir="/tmp"
prefix="pgsql_dump"

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
            tmpdir="${OPTARG}"
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

destination="$(readlink -f "${destination}")"

if [ ! -d "${destination}" ]
then
    printf '%s%s%s not a folder.\n' \' "${destination}" \'
    exit 1
fi

name="${prefix}${classifier}$(generate_timestamp).sql"

dump_pack "${name}" "${@}"

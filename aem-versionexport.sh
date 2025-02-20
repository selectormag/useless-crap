# An attempt to retrieve missing versions from AEM

SOURCECQ="localhost:4502"
SOURCEPASS=$(pass AEMAdmin)
PKGNAME="$(archive_${1})"
PACKGROUP="archive"

# Create new package
curl -s -u admin:"${SOURCEPASS}" -X POST http://"${SOURCECQ}"/crx/packmgr/service/.json/etc/packages/"${PKGNAME}".zip?cmd=create -d packageName="${PKGNAME}" -d groupName="${PACKGROUP}" > /dev/null 2>&1


# Determine package filters
echo  "$(date '+%F %T') INFO: Adding package filters"
i=0

# Clean up old filterlist.tmp, if it exists
rm -vf filterlist.tmp


if [[ "${USEQUERY}" == 'TRUE' ]]; then
        echo "$(date '+%F %T') INFO: Package to be built by query. Executing query."
        while read FILTERRAW; do

                # Parses each FILTERRAW line for the filter path and the associated content type (currently only supports cq:Page, dam:Asset, and cq:Tag, but more could be added with relative ease). Path comes first, separated by a tab, followed by content type.

                FILTER="${FILTERRAW}"
                echo "$(date '+%F %T') INFO: FILTER is ${FILTER}"
                DATEPROPERTY='jcr:content/jcr:lastModified'
                PREVDATE="${1}"

                curl -s -u admin:"${SOURCEPASS}" "http://${SOURCECQ}/bin/querybuilder.json?type=${CTYPE}&path=${FILTER}&daterange.property=${DATEPROPERTY}&daterange.lowerBound=${PREVDATE}&p.limit=-1" | jq -r '.hits[].path' >> filterlist.tmp
        done <filter.list
        FILTERLIST="filterlist.tmp"
fi

while read FILTER; do
    # Add filter to package definition
    echo "$(date '+%F %T') INFO: Adding filter to package definitiion: ${FILTER}"
    curl -s -u admin:"${SOURCEPASS}" \
        -H "Accept:application/json" \
        -F "jcr:primaryType=nt:unstructured" \
        -F mode=replace \
        -F root="${FILTER}"/jcr:content \
#       -F rules="exclude
        http://"${SOURCECQ}"/etc/packages/"${PACKGROUP}"/"${PKGNAME}".zip/jcr%3acontent/vlt%3adefinition/filter/f"${i}" > /dev/null 2>&1
    ((i++))
done <"${FILTERLIST}"

# Build on source instance
echo "$(date '+%F %T') INFO: Building ${PKGNAME} on ${SOURCECQ}"
curl -s -u admin:"${SOURCEPASS}" -X POST http://"${SOURCECQ}"/crx/packmgr/service/.json/etc/packages/"${PACKGROUP}"/"${PKGNAME}".zip?cmd=build > /dev/null 2>&1

# Fetch from source instance
echo "$(date '+%F %T') INFO: Fetching ${PKGNAME} from ${SOURCECQ}"
curl -s -u admin:"${SOURCEPASS}" http://"${SOURCECQ}"/etc/packages/"${PACKGROUP}"/"${PKGNAME}".zip -o "${PKGNAME}".zip > /dev/null 2>&1

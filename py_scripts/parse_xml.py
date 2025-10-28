import sys
import pandas as pd

def parse_xml_tip_dates(infile, outfile, old_sample_ID, new_sample_ID):
    """
    This function reads a BEAST XML file and replaces tip date taxon IDs according to a mapping provided in a CSV file.
    
    ___________USAGE____________
    arg1: input BEAST XML file
    arg2: output BEAST XML file with updated prior for new sample tip dates
    arg3: old sample ID
    arg4: new sample ID

    """
    old_sample_ID = old_sample_ID.strip()
    # print(f'Old sample ID: {old_sample_ID}')
    new_sample_ID = new_sample_ID.strip()
    # print(f'New sample ID: {new_sample_ID}')

    old_sample_tip_ID = '_'.join(old_sample_ID.split('_')[:-1])
    # print(f'Old sample tip ID: {old_sample_tip_ID}')
    new_sample_tip_ID = '_'.join(new_sample_ID.split('_')[:-1])
    # print(f'New sample tip ID: {new_sample_tip_ID}')

    with open(infile, 'r') as file:
        xml_content = file.read()

    xml_content = xml_content.replace(f'taxonset id="{old_sample_tip_ID}"', f'taxonset id="{new_sample_tip_ID}"')
    xml_content = xml_content.replace(f'<taxon id="{old_sample_ID}"', f'<taxon id="{new_sample_ID}"')
    xml_content = xml_content.replace(f'taxonset="@{old_sample_tip_ID}"', f'taxonset="@{new_sample_tip_ID}"')
    xml_content = xml_content.replace(f'id="tipDatesSampler.{old_sample_tip_ID}"', f'id="tipDatesSampler.{new_sample_tip_ID}"')
    xml_content = xml_content.replace(f'id="{old_sample_tip_ID}.prior"', f'id="{new_sample_tip_ID}.prior"')
    xml_content = xml_content.replace(f'idref="{old_sample_tip_ID}.prior"', f'idref="{new_sample_tip_ID}.prior"')

    with open(outfile, 'w') as file:
        file.write(xml_content)


if __name__ == "__main__":
    input_xml = sys.argv[1]
    output_xml = sys.argv[2]
    old_id = sys.argv[3]
    new_id = sys.argv[4]

    parse_xml_tip_dates(input_xml, output_xml, old_id, new_id)

# if __name__ == "__main__":
#     input_xml = sys.argv[1]
#     sample_list_txt = sys.argv[2]

#     id_mapping = read_sample_id_txt(sample_list_txt)
#     old_id = id_mapping[0]
#     # old_id = "Ireland_Newgrange_4744"
#     # print(f'Initial old ID: {old_id}')

#     for i in range(1, len(id_mapping)):
#         new_id = id_mapping[i]
#         # print(f'Processing new ID: {new_id}')
#         # create output file in same directory but with new base name
#         new_basename = f'strictClock_dating{new_id.strip()}.xml'

#         output_xml = new_basename

#         parse_xml_tip_dates(input_xml, output_xml, old_id, new_id)

    # for i in range(len(id_mapping) - 1):

    #     old_id = id_mapping[i]
    #     new_id = id_mapping[i + 1]

    #     # process current mapping (n)
    #     parse_xml_tip_dates(input_xml, output_xml, old_id, new_id)

    #     # update input for the next iteration
    #     input_xml = output_xml

    # # optionally process the final mapping if you need to include the last item
    # old_id, new_id = id_mapping[-1]
    # output_xml = input_xml.replace('.xml', f'basis_21seq_strictClock_dating{new_id}.xml')
    # parse_xml_tip_dates(input_xml, output_xml, old_id, new_id)

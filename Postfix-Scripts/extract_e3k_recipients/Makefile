## Makefile to automate map build process

## configuration settings

# Location of the file we extract the data from
ADS_DUMP=/home/e3k/example_com_recients.txt

# Location of the .proto files
PROTO_PATH=relay_recipients
PROTO_PATH2=valid_senders

# destination of successfully built maps
MAP_PATH=/etc/postfix/relay_recipients
MAP_PATH2=/etc/postfix/valid_senders

# type and suffix of the maps to build
DB_TYPE=hash
DB_SUFFIX=db

## Makefile options
#
# build all maps
all:   			   $(MAP_PATH).$(DB_SUFFIX) $(MAP_PATH2).$(DB_SUFFIX) blacklist
	
# extract valid recipients from $(ADS_DUMP) to $(PROTO_PATH).proto
$(PROTO_PATH).proto:	   $(ADS_DUMP)
			   ./extract_valid_recipients $(ADS_DUMP) $(PROTO_PATH).proto

# extract valid senders from $(ADS_DUMP) to $(PROTO_PATH2).proto
$(PROTO_PATH2).proto:	   $(ADS_DUMP)
			   ./extract_valid_senders $(ADS_DUMP) $(PROTO_PATH2).proto

# build map of valid recipients from $(PROTO_PATH).proto
$(MAP_PATH).$(DB_SUFFIX):  $(PROTO_PATH).proto
			   /usr/sbin/postmap -w $(DB_TYPE):$(PROTO_PATH).proto && \
			   mv $(PROTO_PATH).proto.$(DB_SUFFIX) $(MAP_PATH).$(DB_SUFFIX)

# build map of valid senders from $(PROTO_PATH2).proto
$(MAP_PATH2).$(DB_SUFFIX):  $(PROTO_PATH2).proto
			   /usr/sbin/postmap -w $(DB_TYPE):$(PROTO_PATH2).proto && \
			   mv $(PROTO_PATH2).proto.$(DB_SUFFIX) $(MAP_PATH2).$(DB_SUFFIX)

# remove all proto maps
clean:		
				rm -f $(PROTO_PATH).* $(PROTO_PATH2).* *~

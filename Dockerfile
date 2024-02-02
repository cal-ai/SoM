FROM nvidia/cuda:12.3.1-devel-ubuntu22.04

# Install Python, pip, git, ninja
RUN apt-get update && \
    apt-get install -y python3-pip python3-dev git ninja-build wget && \
    ln -sf /usr/bin/python3 /usr/bin/python && \
    ln -sf /usr/bin/pip3 /usr/bin/pip

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container at /usr/src/app
COPY . .

ENV FORCE_CUDA=1

# Install PyTorch with CUDA support and other dependencies
RUN pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu123 \
    && pip install git+https://github.com/UX-Decoder/Segment-Everything-Everywhere-All-At-Once.git@package \
    && pip install git+https://github.com/facebookresearch/segment-anything.git \
    && pip install git+https://github.com/UX-Decoder/Semantic-SAM.git@package \
    && cd ops && bash make.sh && cd ..

# Run download_ckpt.sh to download the pretrained models
RUN sh download_ckpt.sh

# Make port 80 available to the world outside this container
EXPOSE 80

# Run demo_som.py when the container launches
CMD ["python", "./demo_som.py"]
